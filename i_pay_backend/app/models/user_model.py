from sqlalchemy import Column, Integer, String, ForeignKey
from ..database import Base
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    mobile = Column(Integer, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    active_account_id = Column(Integer, ForeignKey("accounts.id"), nullable=True)

    accounts = relationship(
        "Account",
        back_populates="user",
        foreign_keys="[Account.user_id]"
    )

    active_account = relationship(
        "Account",
        foreign_keys=[active_account_id],
        uselist=False
    )

