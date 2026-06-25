from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from ..database import Base

class ResetPin(Base):
    __tablename__ = "reset_pin"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    account_id = Column(Integer, ForeignKey("accounts.id"), nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)
    status = Column(String, default="pending")
    ip_address = Column(String, nullable=True)
    device_info = Column(String, nullable=True)

    user = relationship("User", backref="reset_pin_requests")
    account = relationship("Account", backref="reset_pin_requests")
