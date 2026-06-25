from pydantic import BaseModel
from typing import List, Dict, Optional
from datetime import datetime

class TransactionPattern(BaseModel):
    category: str
    amount: float
    date: datetime

class FraudAlert(BaseModel):
    id: int
    amount: float
    category: str
    type: str
    date: datetime
    message: str

class AnalyticsResponse(BaseModel):
    total_income: float
    total_expense: float
    net_cash_flow: float
    category_summary: Dict[str, float]
    patterns: Dict[str, List[TransactionPattern]]
    debt_to_income_ratio: Optional[float] = None
    savings_rate: Optional[float] = None
    avg_daily_balance: Optional[float] = None
    fraud_alerts: List[FraudAlert] = []

    class Config:
        orm_mode = True
