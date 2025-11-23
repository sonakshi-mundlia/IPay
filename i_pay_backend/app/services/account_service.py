from sqlalchemy.orm import Session
from ..models.account_model import Account
from ..models.user_model import User
from ..schemas.account_schema import AccountCreate, AccountResponse
from typing import List
import uuid


class AccountService:

    def create_account(self, db: Session, account_data: AccountCreate) -> AccountResponse:
        new_account = Account(
            user_id=account_data.user_id,
            account_number=account_data.account_number,
            balance=account_data.balance,
            vpa_id=f"{uuid.uuid4().hex[:8]}@vpa"
        )
        db.add(new_account)
        db.commit()
        db.refresh(new_account)
        return AccountResponse.from_orm(new_account)

    def get_account(self, db: Session, account_id: int) -> AccountResponse:
        account = db.query(Account).filter(Account.id == account_id).first()
        if not account:
            raise Exception("Account not found")
        return AccountResponse.from_orm(account)

    def get_user_accounts(self, db: Session, user_id: int) -> List[AccountResponse]:
        accounts = db.query(Account).filter(Account.user_id == user_id).all()
        return [AccountResponse.from_orm(acc) for acc in accounts]

    def update_balance(self, db: Session, account_id: int, amount: float) -> AccountResponse:
        account = db.query(Account).filter(Account.id == account_id).first()
        if not account:
            raise Exception("Account not found")
        account.balance += amount
        db.commit()
        db.refresh(account)
        return AccountResponse.from_orm(account)

