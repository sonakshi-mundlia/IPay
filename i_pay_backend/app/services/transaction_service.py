from sqlalchemy.orm import Session
from ..models.transaction_model import Transaction
from ..models.account_model import Account
from ..schemas.transaction_schema import TransactionCreate, TransactionResponse
from ..models.user_model import User
import uuid
from datetime import datetime, timedelta
from jose import jwt, JWTError
from passlib.context import CryptContext
from fastapi import HTTPException

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

SECRET_KEY = "SECRET_KEY"
ALGORITHM = "HS256"

blacklist = set()

def add_token_to_blacklist(token: str):
    blacklist.add(token)

def is_token_blacklisted(token: str) -> bool:
    return token in blacklist

class TransactionService:

    @staticmethod
    def hash_password(password: str) -> str:
        return pwd_context.hash(password)

    @staticmethod
    def verify_password(plain: str, hashed: str) -> bool:
        return pwd_context.verify(plain, hashed)

    @staticmethod
    def create_jwt(data: dict, expires_minutes: int = 520000):
        to_encode = data.copy()
        expire = datetime.utcnow() + timedelta(minutes=expires_minutes)
        to_encode.update({"exp": expire})
        return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

    @staticmethod
    def decode_jwt(token: str):
        if is_token_blacklisted(token):
            return None
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            return payload
        except JWTError:
            return None

    def verify_transaction_pin(self, user: User, pin: str) -> bool:
            return self.verify_password(pin, user.transaction_pin)

    def perform_transaction(self, db: Session, payload: TransactionCreate):
        from_acc = db.query(Account).filter(Account.id == payload.from_account_id).first()
        to_acc = db.query(Account).filter(Account.id == payload.to_account_id).first()
        if not from_acc or not to_acc:
            raise Exception("Account(s) not found")
        if payload.from_account_id == payload.to_account_id:
            raise Exception("Cannot send money to the same account")
        if from_acc.balance < payload.amount:
            raise Exception("Insufficient balance")

        from_acc.balance -= payload.amount
        to_acc.balance += payload.amount

        vpa_ref = str(uuid.uuid4())



        tx = Transaction(
            from_account_id=from_acc.id,
            to_account_id=to_acc.id,
            amount=payload.amount,
            category=payload.category,
            timestamp=datetime.utcnow(),
            vpa_ref=vpa_ref
        )
        db.add(tx)
        db.commit()
        db.refresh(tx)


        resp = TransactionResponse(
            id=tx.id,
            from_name=from_acc.user.name,
            from_vpa_id=from_acc.vpa_id,
            to_name=to_acc.user.name,
            to_vpa_id=to_acc.vpa_id,
            vpa_ref=tx.vpa_ref,
            amount=tx.amount,
            category=tx.category,
            timestamp=tx.timestamp
        )
        return resp


    def get_last_transactions(self, db: Session, account_id: int, limit: int = 5):
        txs = (
            db.query(Transaction)
            .filter((Transaction.from_account_id == Account.id) | (Transaction.to_account_id == Account.id))
            .order_by(Transaction.timestamp.desc())
            .limit(limit)
            .all()
        )

        result = []
        for tx in txs:
            from_acc = db.query(Account).filter(Account.id == tx.from_account_id).first()
            to_acc = db.query(Account).filter(Account.id == tx.to_account_id).first()
            result.append(
                TransactionResponse(
                    id=tx.id,
                    from_name=from_acc.user.name if from_acc else "Unknown",
                    from_vpa_id=from_acc.vpa_id if from_acc else "",
                    to_name=to_acc.user.name if to_acc else "Unknown",
                    to_vpa_id=to_acc.vpa_id if to_acc else "",
                    vpa_ref=tx.vpa_ref,
                    amount=tx.amount,
                    category=tx.category,
                    timestamp=tx.timestamp
                )
            )
        return result
