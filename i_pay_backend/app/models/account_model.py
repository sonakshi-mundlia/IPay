from sqlalchemy import Column, Integer, String, Float, ForeignKey
from sqlalchemy.orm import relationship
from ..database import Base

class Account(Base):
    __tablename__ = "accounts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    bank_name = Column(String, nullable=False)
    account_number = Column(String, unique=True, index=True)
    balance = Column(Float, default=0.0)
    vpa_id = Column(String, unique=True, index=True)

    user = relationship("User", backref="accounts")



