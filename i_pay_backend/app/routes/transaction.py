from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..models.user_model import User
from ..models.account_model import Account
from ..models.transaction_model import Transaction
from ..schemas.transaction_schema import TransactionResponse
from ..services.transaction_service import TransactionService
from ..services.nlp_service import NLPService
from ..database import get_db

router = APIRouter(prefix="/transaction", tags=["Transactions"])
nlp = NLPService()
svc = TransactionService()

@router.post("/", response_model=TransactionResponse)
def interpret_and_send(text: str, db: Session = Depends(get_db)):
    parsed = nlp.parse(text)

    if parsed["intent"] != "send_money":
        raise HTTPException(status_code=400, detail="Invalid intent")

    amount = parsed["amount"]
    receiver = parsed["receiver"]

    if not amount:
        raise HTTPException(status_code=400, detail="Amount not found in input")

    to_acc = db.query(Account).filter(Account.vpa_id.ilike(f"{receiver}%")).first()

    if not to_acc:
        to_acc = (
            db.query(Account)
            .join(Account.user)
            .filter(User.name.ilike(f"%{receiver}%"))
            .first()
        )

    if not to_acc:
        raise HTTPException(status_code=404, detail="Receiver not found")

    from_acc = db.query(Account).first()

    if not from_acc:
        raise HTTPException(status_code=400, detail="Sender account missing")

    success, msg = svc.perform_transaction(db, from_acc, to_acc, amount)

    if not success:
        raise HTTPException(status_code=400, detail=msg)

    return TransactionResponse(
        message=msg,
        amount=amount,
        to=receiver,
        from_account=from_acc.id
    )

@router.get("/history", response_model=List[TransactionResponse])
def get_last_transactions(db: Session = Depends(get_db), user_id: int = 1, limit: int = 5):
    tx_list = (
        db.query(Transaction)
        .join(Account, Transaction.from_account_id == Account.id)
        .filter(Account.user_id == user_id)
        .order_by(Transaction.timestamp.desc())
        .limit(limit)
        .all()
    )

    return [
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
        for tx in tx_list
    ]
