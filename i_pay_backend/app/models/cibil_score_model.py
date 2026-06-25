from sqlalchemy import Column, Integer, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from ..database import Base

class CibilScore(Base):
    __tablename__ = "cibil_scores"

    id = Column(Integer, primary_key=True, index=True)
    score = Column(Integer, nullable=False)
    grade = Column(Integer)
    created_at = Column(DateTime, default=datetime.utcnow)

    account_id = Column(Integer, ForeignKey("accounts.id"))

    account = relationship("Account", back_populates="cibil_scores")
