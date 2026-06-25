from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..dependencies import get_current_user
from ..models.user_model import User
from ..models.account_model import Account
from ..schemas.pin_verify_schema import VerifyPinRequest

router = APIRouter(prefix="/pin", tags=["PIN"])


@router.post("/verify")
def verify_pin(
        data: VerifyPinRequest,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    account = db.query(Account).filter(
        Account.id == data.account_id,
        Account.user_id == current_user.id
    ).first()

    if not account:
        raise HTTPException(status_code=404, detail="Account not found")

    # ⚠️ If hashed, use verify_hash here
    if account.pin != data.pin:
        raise HTTPException(status_code=401, detail="Invalid PIN")

    # ----------------------------
    # ACTION HANDLING
    # ----------------------------
    if data.action == "check_balance":
        return {
            "message": f"Your current balance is {account.balance} rupees.",
            "navigate": "balance_page",
            "balance": account.balance
        }

    return {
        "message": "PIN verified successfully.",
        "navigate": None
    }
