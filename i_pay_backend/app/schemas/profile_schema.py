from pydantic import BaseModel

class ProfileResponse(BaseModel):
    name: str
    email: str
    mobile: str
    vpa_id: str

    class Config:
        from_attributes = True
