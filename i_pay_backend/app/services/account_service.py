from sqlalchemy.orm import Session
from ..models.account_model import Account
from ..models.reset_pin_model import ResetPin
from ..models.user_model import User
from ..database import get_db
from ..dependencies import get_current_user
from ..schemas.account_schema import AccountCreate, AccountResponse
from typing import List
from passlib.context import CryptContext
from fastapi import HTTPException, Depends
from datetime import datetime

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class AccountService:

    def create_account(self, account_data: AccountCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)) -> AccountResponse:
        # 1. Prevent duplicates
        duplicate_account = db.query(Account).filter(
            (Account.account_number == account_data.account_number) |
            (Account.vpa_id == account_data.vpa_id)
        ).first()

        if duplicate_account:
            raise HTTPException(
                status_code=400,
                detail="Account number or VPA ID already exists"
            )

        # 2. Get existing accounts for user
        user_accounts = db.query(Account).filter(
            Account.user_id == account_data.user_id
        ).all()

        # 3. Decide transaction PIN
        if not user_accounts:
            # FIRST ACCOUNT → PIN REQUIRED
            if account_data.transaction_pin and not (
                    account_data.transaction_pin.isdigit() and
                    len(account_data.transaction_pin) == 4
            ):
                raise HTTPException(
                    status_code=400,
                    detail="Transaction PIN must be exactly 4 digits"
                )

            pin_to_use = pwd_context.hash(account_data.transaction_pin)

        else:
            # NEXT ACCOUNTS → REUSE EXISTING PIN
            pin_to_use = user_accounts[0].transaction_pin

            if not pin_to_use:
                raise HTTPException(
                    status_code=500,
                    detail="Existing account has no PIN. Data corrupted."
                )

        # 4. Create account
        new_account = Account(
            user_id=current_user.id,
            account_number=account_data.account_number,
            balance=account_data.balance,
            bank_name=account_data.bank_name,
            ifsc_code=account_data.ifsc_code,
            email=account_data.email,
            mobile=account_data.mobile,
            vpa_id=account_data.vpa_id,
            transaction_pin=pin_to_use
        )

        db.add(new_account)
        db.commit()
        db.refresh(new_account)

        return AccountResponse.from_orm(new_account)

    def reset_transaction_pin(
            self,
            db: Session,
            user_id: int,
            old_pin: str,
            new_pin: str,
            ip: str = None,
            device: str = None
    ):
        accounts = db.query(Account).filter(Account.user_id == user_id).all()
        if not accounts:
            raise HTTPException(status_code=404, detail="User has no accounts")

        log_entry = ResetPin(
            user_id=user_id,
            account_id=accounts[0].id,
            status="pending",
            ip_address=ip,
            device_info=device
        )
        db.add(log_entry)
        db.commit()
        db.refresh(log_entry)

        stored_pin = next((a.transaction_pin for a in accounts if a.transaction_pin), None)
        if not stored_pin:
            log_entry.status = "failed"
            db.commit()
            raise HTTPException(status_code=400, detail="PIN not set yet")

        if not pwd_context.verify(old_pin, stored_pin):
            log_entry.status = "failed"
            db.commit()
            raise HTTPException(status_code=401, detail="Old PIN is incorrect")

        new_hashed_pin = pwd_context.hash(new_pin)
        for acc in accounts:
            acc.transaction_pin = new_hashed_pin

        log_entry.status = "success"
        log_entry.timestamp = datetime.utcnow()
        db.commit()

        return {"message": "Transaction PIN updated successfully"}

    def get_account(self, db: Session, account_id: int) -> AccountResponse:
        account = db.query(Account).filter(Account.id == account_id).first()
        if not account:
            raise HTTPException(status_code=404, detail="Account not found")
        return AccountResponse.from_orm(account)

    def get_user_accounts(self, db: Session, user_id: int) -> List[AccountResponse]:
        accounts = db.query(Account).filter(Account.user_id == user_id).all()
        return [AccountResponse.from_orm(acc) for acc in accounts]

    def update_balance(self, db: Session, account_id: int, amount: float) -> AccountResponse:
        account = db.query(Account).filter(Account.id == account_id).first()
        if not account:
            raise HTTPException(status_code=404, detail="Account not found")
        account.balance += amount
        db.commit()
        db.refresh(account)
        return AccountResponse.from_orm(account)
