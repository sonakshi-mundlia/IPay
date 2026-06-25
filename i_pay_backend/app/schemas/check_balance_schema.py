from pydantic import BaseModel, Field

class CheckBalanceRequest(BaseModel):
    transaction_pin: str = Field(..., min_length=4, max_length=4)
    account_id: int

class CheckBalanceResponse(BaseModel):
    account_number: str
    bank_name: str
    balance: float

    class Config:
        orm_mode = True
