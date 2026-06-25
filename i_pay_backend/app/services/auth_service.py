from passlib.context import CryptContext
from jose import jwt, JWTError
from datetime import datetime, timedelta
from fastapi import HTTPException
from ..schemas.user_schema import UserCreate
from sqlalchemy.orm import Session
from ..models.user_model import User
from ..config import SECRET_KEY


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

SECRET_KEY=SECRET_KEY
ALGORITHM = "HS256"

blacklist = set()

def add_token_to_blacklist(token: str):
    blacklist.add(token)

def is_token_blacklisted(token: str) -> bool:
    return token in blacklist


class AuthService:

    @staticmethod
    def hash_password(password: str) -> str:
        return pwd_context.hash(password)

    @staticmethod
    def verify_password(plain: str, hashed: str) -> bool:
        return pwd_context.verify(plain, hashed)

    @staticmethod
    def create_jwt(data: dict, expires_minutes: int = 525600):
        to_encode = data.copy()
        expire = datetime.utcnow() + timedelta(minutes=expires_minutes)
        to_encode.update({"exp": expire})
        return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

    @staticmethod
    def decode_jwt(token: str):
        if is_token_blacklisted(token):
            return None
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            return payload
        except JWTError:
            return None

    def register_user(self, db: Session, user_data: UserCreate):
        existing_user = db.query(User).filter(
            (User.email == user_data.email) | (User.mobile == user_data.mobile)
        ).first()
        if existing_user:
            raise HTTPException(status_code=400, detail="User already exists")

        hashed_password = pwd_context.hash(user_data.password)

        new_user = User(
            name=user_data.name,
            email=user_data.email,
            mobile=user_data.mobile,
            hashed_password=hashed_password
        )

        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        return new_user

    def authenticate_user(self, db: Session, email: str | None, mobile: int | None, password: str):
        if email is None and mobile is None:
            return None
        if email:
            user = db.query(User).filter(User.email == email).first()
        elif mobile:
            user = db.query(User).filter(User.mobile == mobile).first()
        else:
            return None

        if not user or not self.verify_password(password, user.hashed_password):
            return None

        return user


