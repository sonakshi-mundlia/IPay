from sqlalchemy.orm import Session
from ..models.user_model import User

class ProfileService:

    @staticmethod
    def get_user_profile(db: Session, user_id: int) -> User:
        return db.query(User).filter(User.id == user_id).first()
