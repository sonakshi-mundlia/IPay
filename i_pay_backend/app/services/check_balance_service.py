from sqlalchemy.orm import Session
from fastapi import HTTPException
from ..models.account_model import Account
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class CheckBalanceService:

    @staticmethod
    def check_balance(db: Session, user_id: int, account_id: int, transaction_pin: str):

        # Fetch user account
        account = (
            db.query(Account)
            .filter(Account.id == account_id, Account.user_id == user_id)
            .first()
        )

        if not account:
            raise HTTPException(status_code=404, detail="Account not found")

        if not pwd_context.verify(transaction_pin, account.transaction_pin):
            raise HTTPException(status_code=403, detail="Invalid transaction PIN")

        # MASK THE ACCOUNT NUMBER HERE

        account_number = account.account_number or ""

        if len(account_number) > 4:
            masked_account = "X" * (len(account_number) - 4) + account_number[-4:]
        else:
            masked_account = account_number

        # Return masked number
        return {
            "account_number": masked_account,
            "bank_name": account.bank_name,
            "balance": float(account.balance),
        }
check_balance_service = CheckBalanceService()
