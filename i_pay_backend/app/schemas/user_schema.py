from pydantic import BaseModel,EmailStr, conint
from .account_schema import AccountResponse
from typing import List

class UserCreate(BaseModel):
    name: str
    email: EmailStr | None = None
    mobile: conint(ge=1000000000, le=999999999999999) | None = None
    password: str

class UserLogin(BaseModel):
    email: str | None = None

    mobile: conint(ge=1000000000, le=999999999999999) | None = None
    password: str

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    mobile: int

class UserProfileResponse(BaseModel):
    id: int
    name: str
    email: str
    mobile: int
    active_account_id: int | None
    accounts: List[AccountResponse]

    class Config:
        orm_mode = True
