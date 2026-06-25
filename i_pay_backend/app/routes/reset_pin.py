from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..schemas.reset_pin_schema import ResetPinRequest, ResetPinResponse
from ..services.account_service import AccountService

router = APIRouter(prefix="/pin", tags=["PIN"])
account_service = AccountService()

@router.put("/reset", response_model=ResetPinResponse)
def reset_pin(data: ResetPinRequest, db: Session = Depends(get_db)):
    return account_service.reset_transaction_pin(
        db=db,
        user_id=data.user_id,
        old_pin=data.old_pin,
        new_pin=data.new_pin,
        ip=data.ip_address,
        device=data.device_info
    )
