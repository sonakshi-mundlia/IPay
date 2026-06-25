from pydantic import BaseModel, Field

class ResetPinRequest(BaseModel):
    user_id: int
    old_pin: str = Field(..., min_length=4, max_length=4)
    new_pin: str = Field(..., min_length=4, max_length=4)
    ip_address: str | None = None
    device_info: str | None = None

class ResetPinResponse(BaseModel):
    message: str
