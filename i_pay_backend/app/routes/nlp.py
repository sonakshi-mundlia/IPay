from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..dependencies import get_current_user
from ..services.nlp_service import NLPService, translate_text

from ..services.transaction_service import TransactionService
from ..services.account_service import AccountService
from ..services.cibil_score_service import CibilService
from ..services.loan_apply_service import LoanApplyService
from ..services.bill_pay_service import BillPayService
from ..services.recharge_service import RechargeService
from ..services.profile_service import ProfileService
from ..services.analytics_service import AnalyticsService

from ..models.user_model import User
from ..models.account_model import Account
from ..schemas.nlp_schema import NLPResponse, NLPRequest

router = APIRouter()

nlp = NLPService()


@router.post("/nlp", response_model=NLPResponse)
def nlp_assistant(
        request: NLPRequest,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    txn_svc = TransactionService()
    account_svc = AccountService()
    cibil_svc = CibilService()
    loan_svc = LoanApplyService()
    bill_svc = BillPayService()
    recharge_svc = RechargeService()
    profile_svc = ProfileService()
    analytics_svc = AnalyticsService(db)

    parsed = nlp.parse(request.text)

    lang = parsed.get("lang", "en")
    intent = parsed.get("intent", "unknown")
    amount = parsed.get("amount")
    receiver_name = parsed.get("receiver")

    def tr(msg: str) -> str:
        translated = translate_text(msg, lang)
        return translated if translated and translated.strip() else msg

    def safe_speech(msg: str) -> str:
        """Guarantee non-empty speech"""
        text = tr(msg)
        return text if text.strip() else tr("Okay.")

    # --------------------------------------------------
    # ACCOUNT VALIDATION
    # --------------------------------------------------
    if not request.account_id:
        return NLPResponse(
            speech=safe_speech("Please select an account first."),
            intent="select_account",
            navigate="account_select_page"
        )

    account = db.query(Account).filter(
        Account.id == request.account_id,
        Account.user_id == current_user.id
    ).first()

    if not account:
        raise HTTPException(status_code=403, detail="Invalid account")

    # --------------------------------------------------
    # PROFILE
    # --------------------------------------------------
    if intent == "profile":
        speech=safe_speech("Opening your profile.")
        print("🔥 BACKEND SPEECH:", speech)
        return NLPResponse(
            speech=speech,
            intent=intent,
            navigate="profile_page",
            extra={"account_id": account.id}
        )

    # --------------------------------------------------
    # CHECK BALANCE (PIN)
    # --------------------------------------------------
    if intent == "check_balance":
        return NLPResponse(
            speech=safe_speech("Please enter your PIN to check your balance."),
            intent=intent,
            navigate="pin_page",
            extra={
                "action": "check_balance",
                "account_id": account.id
            }
        )

    # --------------------------------------------------
    # SEND MONEY
    # --------------------------------------------------
    if intent == "send_money":
        if not amount or not receiver_name:
            return NLPResponse(
                speech=safe_speech("Please tell me the amount and receiver name."),
                intent=intent,
                navigate="transaction_page",
                extra={"account_id": account.id}
            )

        return NLPResponse(
            speech=safe_speech("Please enter your PIN to confirm the payment."),
            intent=intent,
            navigate="pin_page",
            extra={
                "action": "send_money",
                "amount": amount,
                "receiver": receiver_name,
                "account_id": account.id
            }
        )

    # --------------------------------------------------
    # TRANSACTION HISTORY
    # --------------------------------------------------
    if intent == "transaction_history":
        history = txn_svc.get_last_transactions(
            db=db,
            account_id=account.id,
            limit=5
        )

        if not history:
            return NLPResponse(
                speech=safe_speech("You have no recent transactions."),
                intent=intent,
                navigate="history_page",
                extra={"account_id": account.id}
            )

        spoken = "; ".join(
            f"{t.amount} rupees on {t.timestamp.strftime('%d %b')}"
            for t in history
        )

        return NLPResponse(
            speech=safe_speech(f"Your recent transactions are: {spoken}."),
            intent=intent,
            navigate="history_page",
            extra={"account_id": account.id}
        )

    # --------------------------------------------------
    # CIBIL SCORE
    # --------------------------------------------------
    if intent == "cibil_score":
        report = cibil_svc.get_score(db=db, account_id=account.id)

        return NLPResponse(
            speech=safe_speech("Your credit score details are ready."),
            intent=intent,
            navigate="cibil_page",
            extra={
                "account_id": account.id,
                "cibil_report": report
            }
        )

    if intent == "analytics":
        report = analytics_svc.generate_report(account_id=account.id)

        return NLPResponse(
            speech=safe_speech("Opening analytics."),
            intent=intent,
            navigate="analytics_page",
            extra={
                "account_id": account.id,
                "analytics": report
            }
        )

    # --------------------------------------------------
    # SIMPLE NAVIGATION (FIXED)
    # --------------------------------------------------
    page_map = {
        "add_account": ("add_account_page", "Opening add account page."),
        "bill_pay": ("bill_pay_page", "Opening bill payment."),
        "loan_apply": ("loan_page", "Opening loan application."),
        "bank_transfer": ("bank_transfer_page", "Opening bank transfer page."),
        "recharge_pay": ("recharge_page", "Opening recharge."),
    }

    if intent in page_map:
        page, msg = page_map[intent]
        return NLPResponse(
            speech=safe_speech(msg),
            intent=intent,
            navigate=page,
            extra={"account_id": account.id}
        )

    # --------------------------------------------------
    # HELP
    # --------------------------------------------------
    if intent == "help":
        return NLPResponse(
            speech=safe_speech(
                "You can say check balance, send money, show history, "
                "check credit score, pay bills, apply for loans, or recharge."
            ),
            intent=intent
        )

    # --------------------------------------------------
    # UNKNOWN (SAFE)
    # --------------------------------------------------
    return NLPResponse(
        speech=safe_speech("Sorry, I did not understand that. Please try again."),
        intent="unknown"
    )
