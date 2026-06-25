from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from sqlalchemy import or_
from ..models.user_model import User
from ..models.account_model import Account
from ..models.transaction_model import Transaction
from ..schemas.transaction_schema import TransactionCreate, TransactionResponse
from ..services.transaction_service import TransactionService
from ..services.nlp_service import NLPService
from ..database import get_db
from ..schemas.check_balance_schema import CheckBalanceRequest, CheckBalanceResponse
from ..services.check_balance_service import check_balance_service
from ..dependencies import get_current_user

router = APIRouter(prefix="/transaction", tags=["Transactions"])
nlp = NLPService()
svc = TransactionService()

@router.post("/", response_model=TransactionResponse)
def interpret_and_send(
        text: str,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    parsed = nlp.parse(text)

    if parsed.get("intent") != "send_money":
        raise HTTPException(status_code=400, detail="Invalid intent")

    amount = parsed.get("amount")
    receiver = parsed.get("receiver")

    if not amount or amount <= 0:
        raise HTTPException(status_code=400, detail="Invalid amount")

    if not receiver:
        raise HTTPException(status_code=400, detail="Receiver not found in input")

    # 🔐 Sender account (must belong to logged-in user)
    from_acc = (
        db.query(Account)
        .filter(Account.user_id == current_user.id)
        .first()
    )

    if not from_acc:
        raise HTTPException(status_code=400, detail="Sender account missing")

    # 🔎 Find receiver account by VPA
    to_acc = (
        db.query(Account)
        .filter(Account.vpa_id.ilike(f"{receiver}%"))
        .first()
    )

    # 🔎 Fallback: find by user name
    if not to_acc:
        to_acc = (
            db.query(Account)
            .join(Account.user)
            .filter(User.name.ilike(f"%{receiver}%"))
            .first()
        )

    if not to_acc:
        raise HTTPException(status_code=404, detail="Receiver not found")

    # ❌ Block same-account transfer
    if from_acc.id == to_acc.id:
        raise HTTPException(
            status_code=400,
            detail="Sender and receiver account cannot be same"
        )

    # 🧠 Perform transaction (account → account)
    tx = svc.perform_transaction(
        db=db,
        payload=TransactionCreate(
            from_account_id=from_acc.id,
            to_account_id=to_acc.id,
            amount=amount,
            category="NLP_TRANSFER"
        )
    )

    return tx

@router.post("/send", response_model=TransactionResponse)
def send_transaction(
        transaction: TransactionCreate,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    # ✅ Check sender account belongs to current user
    from_acc = (
        db.query(Account)
        .filter(Account.id == transaction.from_account_id, Account.user_id == current_user.id)
        .first()
    )
    if not from_acc:
        raise HTTPException(status_code=400, detail="Sender account missing or invalid")

    # ✅ Get receiver account
    to_acc = db.query(Account).filter(Account.id == transaction.to_account_id).first()
    if not to_acc:
        raise HTTPException(status_code=404, detail="Receiver account not found")

    # ❌ Block same-account transfer
    if from_acc.id == to_acc.id:
        raise HTTPException(status_code=400, detail="Sender and receiver account cannot be same")

    # 🧠 Perform transaction
    tx = svc.perform_transaction(
        db=db,
        payload=TransactionCreate(
            from_account_id=from_acc.id,
            to_account_id=to_acc.id,
            amount=transaction.amount,
            category=transaction.category
        )
    )
    return tx



@router.get("/history", response_model=List[TransactionResponse])
def get_last_transactions(
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
        limit: int = 5
):
    tx_list = (
        db.query(Transaction)
        .join(
            Account,
            (Transaction.from_account_id == Account.id) |
            (Transaction.to_account_id == Account.id)
        )
        .filter(Account.user_id == current_user.id)
        .order_by(Transaction.timestamp.desc())
        .limit(limit)
        .all()
    )

    result = []
    for tx in tx_list:
        result.append(
            TransactionResponse(
                id=tx.id,
                from_name=tx.from_account.user.name,
                from_vpa_id=tx.from_account.vpa_id,
                to_name=tx.to_account.user.name,
                to_vpa_id=tx.to_account.vpa_id,
                vpa_ref=tx.vpa_ref,
                amount=tx.amount,
                category=tx.category,
                timestamp=tx.timestamp
            )
        )

    return result



@router.post("/check-balance", response_model=CheckBalanceResponse)
def check_balance(
        data: CheckBalanceRequest,
        current_user: User = Depends(get_current_user),
        db: Session = Depends(get_db)
):
    return check_balance_service.check_balance(
        db=db,
        user_id=current_user.id,
        account_id=data.account_id,
        transaction_pin=data.transaction_pin
    )

@router.get("/recent/{account_id}")
def get_recent_names(
        account_id: int,
        limit: int = 5,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    # 🔐 Ensure account belongs to user
    account = (
        db.query(Account)
        .filter(Account.id == account_id, Account.user_id == current_user.id)
        .first()
    )

    if not account:
        raise HTTPException(status_code=404, detail="Account not found")

    transactions = (
        db.query(Transaction)
        .filter(
            or_(
                Transaction.from_account_id == account_id,
                Transaction.to_account_id == account_id
            )
        )
        .order_by(Transaction.timestamp.desc())
        .limit(limit)
        .all()
    )

    recent_names = []

    for tx in transactions:
        if tx.from_account_id == account_id:
            # you sent → show receiver name
            recent_names.append(tx.to_account.user.name)
        else:
            # you received → show sender name
            recent_names.append(tx.from_account.user.name)

    return {
        "recent": recent_names
    }
