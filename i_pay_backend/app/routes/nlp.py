from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Optional, List

from ..database import get_db
from ..dependencies import get_current_user
from ..services.nlp_service import NLPService
from ..services.transaction_service import TransactionService
from ..models.user_model import User
from ..models.account_model import Account
from ..models.transaction_model import Transaction
from ..schemas.nlp_schema import NLPResponse
from ..services.translate_service import translate_text

router = APIRouter()

nlp = NLPService()
svc = TransactionService()


@router.post("/nlp", response_model=NLPResponse)
def nlp_assistant(
        text: str,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):


    parsed = nlp.parse(text)
    lang = parsed["lang"]
    intent = parsed["intent"]
    amount = parsed.get("amount")
    receiver_name = parsed.get("receiver")

    def tr(msg: str):
        return translate_text(msg, lang)

    if intent == "check_balance":
        account = db.query(Account).filter(Account.user_id == current_user.id).first()
        if not account:
            raise HTTPException(status_code=404, detail="User account not found")

        return NLPResponse(
            message=tr(f"Your balance is {account.balance} rupees."),
            intent=intent
        )

    if intent == "send_money":
        if not amount:
            return NLPResponse(
                message=tr("Please specify the amount to send."),
                intent=intent
            )

        if not receiver_name:
            return NLPResponse(
                message=tr("Please specify the receiver name or VPA."),
                intent=intent
            )

        to_acc: Optional[Account] = db.query(Account).filter(
            Account.vpa_id.ilike(f"{receiver_name}%")
        ).first()

        if not to_acc:
            to_acc = db.query(Account).join(Account.user).filter(
                User.name.ilike(f"%{receiver_name}%")
            ).first()

        if not to_acc:
            return NLPResponse(
                message=tr(f"Receiver '{receiver_name}' not found."),
                intent=intent
            )

        from_acc: Optional[Account] = db.query(Account).filter(
            Account.user_id == current_user.id
        ).first()

        if not from_acc:
            return NLPResponse(
                message=tr("Your account was not found."),
                intent=intent
            )

        # Execute transaction
        success, msg = svc.perform_transaction(db, from_acc, to_acc, amount)
        if not success:
            return NLPResponse(
                message=tr(msg),
                intent=intent
            )

        return NLPResponse(
            message=tr(f"Transaction successful. Sent {amount} rupees to {to_acc.user.name}."),
            intent=intent
        )

    if intent == "transaction_history":
        history: List[Transaction] = svc.get_last_transactions(db, user_id=current_user.id, limit=5)

        if not history:
            return NLPResponse(
                message=tr("You do not have any recent transactions."),
                intent=intent
            )

        spoken = "Here are your last transactions: "
        for t in history:
            spoken += f"{t.amount} rupees to {t.receiver_name}. "

        return NLPResponse(
            message=tr(spoken),
            intent=intent
        )
    if intent == "add_account":
        return NLPResponse(
            message=tr("Please provide account number, IFSC code, and account holder name."),
            intent=intent
        )

    if intent == "help":
        return NLPResponse(
            message=tr(
                "You can ask: what is my balance, send money, show transaction history, "
                "add account, or help."
            ),
            intent=intent
        )

    return NLPResponse(
        message=tr("Sorry, I did not understand that. Please say again."),
        intent="unknown"
    )
