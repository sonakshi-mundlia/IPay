from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models.user_model import User
from ..models.account_model import Account
from ..schemas.account_schema import AccountCreate, AccountResponse
from ..dependencies import get_current_user
from ..schemas.check_balance_schema import CheckBalanceRequest, CheckBalanceResponse
from ..services.account_service import AccountService

router = APIRouter(
    prefix="/accounts",
    tags=["Accounts"]
)
account_service = AccountService()

@router.get("/", response_model=List[AccountResponse])
def get_my_accounts(
        current_user: User = Depends(get_current_user),
        db: Session = Depends(get_db)
):
    accounts = db.query(Account).filter(Account.user_id == current_user.id).all()
    return accounts

@router.post("/add-account", response_model=AccountResponse)
def add_account(
        account_data: AccountCreate,
        current_user: User = Depends(get_current_user),
        db: Session = Depends(get_db)
):
    print("Received Data:", account_data.dict())

    existing = db.query(Account).filter(Account.vpa_id == account_data.vpa_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="VPA already exists")

    new_account = Account(
        user_id=current_user.id,
        bank_name=account_data.bank_name,
        vpa_id=account_data.vpa_id,
        ifsc_code=account_data.ifsc_code,
        balance=account_data.balance,
        account_number=account_data.account_number,
        transaction_pin=account_data.transaction_pin,
        email=account_data.email,
        mobile=account_data.mobile
    )

    db.add(new_account)
    db.commit()
    db.refresh(new_account)

    return new_account

@router.get("/{account_id}", response_model=AccountResponse)
def get_account_by_id(
        account_id: int,
        current_user: User = Depends(get_current_user),
        db: Session = Depends(get_db)
):
    account = db.query(Account).filter(Account.id == account_id, Account.user_id == current_user.id).first()
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")
    return account


@router.delete("/delete-account/{account_id}")
def delete_account(account_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    account = db.query(Account).filter(Account.id == account_id, Account.user_id == current_user.id).first()

    if not account:
        raise HTTPException(status_code=404, detail="Account not found or you don't have permission to delete it")

    db.delete(account)
    db.commit()

    return {"message": "Account deleted successfully", "account_id": account_id}

@router.get("/available/")
def get_available_accounts(
        exclude_account_id: int,
        db: Session = Depends(get_db),
        current_user=Depends(get_current_user)
):
    accounts = (
        db.query(Account)
        .filter(
            Account.user_id == current_user.id,
            Account.id != exclude_account_id
        )
        .all()
    )
    result = [
        {
            "bank_name": acc.bank_name,
            "id": acc.id,
            "account_number": acc.account_number,
            "account_name": acc.user.name,
            "ifsc_code": acc.ifsc_code
        }
        for acc in accounts
    ]

    return result

@router.post("/set-active/{account_id}")
def set_active_account(
        account_id: int,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    account = db.query(Account).filter(
        Account.id == account_id,
        Account.user_id == current_user.id
    ).first()

    if not account:
        raise HTTPException(status_code=404, detail="Account not found")

    current_user.active_account_id = account_id
    db.commit()

    return {"message": "Active account updated", "account_id": account_id}
