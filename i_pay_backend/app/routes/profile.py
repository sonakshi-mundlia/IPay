from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..schemas.profile_schema import ProfileResponse
from ..services.profile_service import ProfileService
from ..database import get_db
from ..dependencies import get_current_user

router = APIRouter(prefix="/profile", tags=["Profile"])
profile_service = ProfileService()

@router.get("/", response_model=ProfileResponse)
def get_profile(current_user=Depends(get_current_user), db: Session = Depends(get_db)):
    user = profile_service.get_user_profile(db, current_user.id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
