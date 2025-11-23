from pydantic import BaseModel

class AccountCreate(BaseModel):
    user_id: int
    bank_name: str
    vpa_id: str
    account_number: str
    ifsc_code: str
    balance: float
    transaction_pin: str

class AccountResponse(BaseModel):
    id: int
    bank_name: str
    user_id: int
    balance: float
    vpa_id: str

    class Config:
        from_attributes = True
