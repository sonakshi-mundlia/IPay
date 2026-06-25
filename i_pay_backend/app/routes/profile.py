from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.user_model import User
from ..schemas.user_schema import UserProfileResponse
from .auth import get_current_user

router = APIRouter(prefix="/profile", tags=["Profile"])

@router.get("/", response_model=UserProfileResponse)
def get_profile(
        current_user=Depends(get_current_user),
        db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == current_user.id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Return user info along with active account
    return {
        "id": user.id,
        "name": user.name,
        "email": user.email,
        "mobile": user.mobile,
        "active_account_id": user.active_account_id,
        "accounts": user.accounts,
    }
