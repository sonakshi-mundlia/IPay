from pydantic import BaseModel
from typing import Optional, Dict, Any

class NLPRequest(BaseModel):
    text: str
    account_id: Optional[int] = None
    lang: Optional[str] = "en"

class NLPResponse(BaseModel):
    speech: str
    intent: str
    navigate: Optional[str] = None
    extra: Optional[Dict[str, Any]] = None


    class Config:
        from_attributes = True
