from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class CibilCreate(BaseModel):
    account_id: int

class CibilResponse(BaseModel):
    score: int
    category: str
    explanation: str
    calculation: str
    pros: List[str]
    cons: List[str]
    help: dict
    created_at: datetime

    class Config:
        orm_mode = True
