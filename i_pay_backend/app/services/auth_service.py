from passlib.context import CryptContext
from jose import jwt, JWTError
from datetime import datetime, timedelta
from ..models.user_model import User

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

SECRET_KEY = "your-secret-key"
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

    def register_user(self, db, user):
        hashed_password = self.hash_password(user.password)
        hashed_pin = self.hash_password(user.transaction_pin)
        new_user = User(
            name=user.name,
            email=user.email,
            mobile=user.mobile,
            hashed_password=hashed_password,
            transaction_pin=hashed_pin
        )
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        return new_user

    def authenticate_user(self, db, email_or_mobile: str, password: str):
        user = db.query(User).filter(
            (User.email == email_or_mobile) | (User.mobile == email_or_mobile)
        ).first()
        if not user or not self.verify_password(password, user.hashed_password):
            return None
        return user

