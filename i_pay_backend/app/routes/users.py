from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.user_model import User

router = APIRouter(prefix="/users", tags=["Users"])

@router.get("/search")
def search_users(
        q: str = Query(..., min_length=3),
        db: Session = Depends(get_db),
):
    users = (
        db.query(User)
        .filter(
            (User.name.ilike(f"%{q}%")) |
            (User.mobile.ilike(f"%{q}%"))
        )
        .limit(10)
        .all()
    )

    return [
        {
            "id": u.id,
            "name": u.name,
            "mobile": u.mobile
        }
        for u in users
    ]
