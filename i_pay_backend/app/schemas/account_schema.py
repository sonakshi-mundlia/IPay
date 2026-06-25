from pydantic import BaseModel, Field
from typing import Optional

class AccountCreate(BaseModel):
    bank_name: str
    vpa_id: str
    account_number: str
    ifsc_code: str
    balance: float
    transaction_pin: Optional[str] = Field(
        None,
        description="4-digit transaction PIN (required only for first account)"
    )
    email: str
    mobile: str

class AccountResponse(BaseModel):
    id: int
    bank_name: str
    user_id: int
    balance: float
    vpa_id: str
    account_number: str | None = None
    transaction_pin: str | None = None
    ifsc_code: str | None = None
    email: str
    mobile: str

    class Config:
        from_attributes = True
