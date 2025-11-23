from pydantic import BaseModel,EmailStr, constr

class UserCreate(BaseModel):
    name: str
    email: EmailStr | None = None
    mobile: constr(min_length=10, max_length=15) | None = None
    password: str
    transaction_pin: str

class UserLogin(BaseModel):
    email_or_mobile: str
    password: str


class UserResponse(BaseModel):
    id: int
    name: str
    email: str



    class Config:
        orm_mode = True
