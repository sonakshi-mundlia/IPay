from pydantic import BaseModel

class VerifyPinRequest(BaseModel):
    account_id: int
    pin: str
    action: str
