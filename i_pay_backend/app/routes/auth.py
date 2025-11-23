from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from ..models.user_model import Base, User
from ..schemas.user_schema import UserCreate, UserLogin
from ..services.auth_service import AuthService, add_token_to_blacklist

DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(bind=engine)
Base.metadata.create_all(bind=engine)

router = APIRouter(
    prefix="/auth",
    tags=["Auth"]
)
auth_service = AuthService()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_current_user(authorization: str = Header(...), db: Session = Depends(get_db)):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token")
    token = authorization.split(" ")[1]
    payload = auth_service.decode_jwt(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Token expired or revoked")
    user = db.query(User).filter(User.id == payload.get("user_id")).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user, token

@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    db_user = auth_service.register_user(db, user)
    return {"message": "User registered successfully", "user_id": db_user.id}


@router.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = auth_service.authenticate_user(db, user.email_or_mobile, user.password)
    if not db_user:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = auth_service.create_jwt({"user_id": db_user.id})
    return {"access_token": token, "token_type": "bearer"}


@router.post("/logout")
def logout(current=Depends(get_current_user)):
    user, token = current
    add_token_to_blacklist(token)
    return {"message": "Logged out successfully"}