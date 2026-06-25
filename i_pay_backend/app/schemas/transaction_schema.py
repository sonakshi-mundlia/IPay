from pydantic import BaseModel
from datetime import datetime

class TransactionCreate(BaseModel):
    from_account_id: int
    to_account_id: int
    amount: float
    category: str

class TransactionResponse(BaseModel):
    id: int
    from_name: str
    from_vpa_id: str
    to_name: str
    to_vpa_id: str
    vpa_ref: str
    amount: float
    category: str
    timestamp: datetime

    class Config:
        from_attributes = True
