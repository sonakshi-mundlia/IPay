from sqlalchemy import Column, Integer, String, Float, ForeignKey
from sqlalchemy.orm import relationship
from ..database import Base

class Account(Base):
    __tablename__ = "accounts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    bank_name = Column(String, nullable=False)
    account_number = Column(String, unique=True, index=True)
    ifsc_code = Column(String, nullable=False)
    balance = Column(Float, default=0.0)
    vpa_id = Column(String, unique=True, index=True)
    transaction_pin = Column(String, nullable=True)
    email = Column(String, nullable=False)
    mobile = Column(String, nullable=False)

    user = relationship("User", back_populates="accounts", foreign_keys=[user_id])
    cibil_scores = relationship("CibilScore", back_populates="account", cascade="all, delete-orphan")

    sent_transactions = relationship(
        "Transaction",
        foreign_keys="Transaction.from_account_id",
        back_populates="from_account"
    )

    received_transactions = relationship(
        "Transaction",
        foreign_keys="Transaction.to_account_id",
        back_populates="to_account"
    )

