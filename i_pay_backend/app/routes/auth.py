from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session

from ..database import get_db
from ..models.user_model import User
from ..schemas.user_schema import UserCreate, UserLogin
from ..services.auth_service import AuthService, add_token_to_blacklist

router = APIRouter(
    prefix="/auth",
    tags=["Auth"]
)

auth_service = AuthService()


def get_current_user(
        authorization: str = Header(None, alias="Authorization"),
        db: Session = Depends(get_db)
):
    if authorization is None:
        raise HTTPException(
            status_code=401,
            detail="Authorization header missing"
        )

    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401,
            detail="Invalid token format"
        )

    token = authorization.split(" ")[1]

    payload = auth_service.decode_jwt(token)

    if not payload:
        raise HTTPException(
            status_code=401,
            detail="Token expired or revoked"
        )

    user = db.query(User).filter(
        User.id == payload.get("user_id")
    ).first()

    if not user:
        raise HTTPException(
            status_code=401,
            detail="User not found"
        )

    return user


def get_current_user_and_token(
        authorization: str = Header(None, alias="Authorization"),
        db: Session = Depends(get_db)
):
    if authorization is None:
        raise HTTPException(
            status_code=401,
            detail="Authorization header missing"
        )

    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401,
            detail="Invalid token format"
        )

    token = authorization.split(" ")[1]

    payload = auth_service.decode_jwt(token)

    if not payload:
        raise HTTPException(
            status_code=401,
            detail="Token expired or revoked"
        )

    user = db.query(User).filter(
        User.id == payload.get("user_id")
    ).first()

    if not user:
        raise HTTPException(
            status_code=401,
            detail="User not found"
        )

    return user, token


@router.post("/register")
def register(
        user: UserCreate,
        db: Session = Depends(get_db)
):
    db_user = auth_service.register_user(db, user)

    return {
        "message": "User registered successfully",
        "user_id": db_user.id
    }


@router.post("/login")
def login(
        user: UserLogin,
        db: Session = Depends(get_db)
):
    if not user.email and not user.mobile:
        raise HTTPException(
            status_code=400,
            detail="Email or mobile must be provided"
        )

    db_user = auth_service.authenticate_user(
        db,
        email=user.email,
        mobile=user.mobile,
        password=user.password
    )

    if not db_user:
        raise HTTPException(
            status_code=401,
            detail="Invalid credentials"
        )

    token = auth_service.create_jwt(
        {"user_id": db_user.id}
    )

    return {
        "access_token": token,
        "token_type": "bearer"
    }


@router.post("/logout")
def logout(
        current=Depends(get_current_user_and_token)
):
    user, token = current

    add_token_to_blacklist(token)

    return {
        "message": "Logged out successfully"
    }

