from pydantic import BaseModel
from typing import Optional

class AnalyticsResponse(BaseModel):
    total_sent: float
    total_received: float
    num_transactions: int
    category: Optional[str] = None
    description: Optional[str] = None

    class Config:
        from_attributes = True
