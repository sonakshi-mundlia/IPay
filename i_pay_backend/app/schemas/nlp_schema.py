from pydantic import BaseModel

class NLPResponse(BaseModel):
    message: str
    intent: str

    class Config:
        from_attributes = True
