from pydantic import BaseModel
from typing import List

class FAQResponse(BaseModel):
    question: str
    answer: str


class HelpRequest(BaseModel):
    question: str

class HelpAnswer(BaseModel):
    answer: str


    class Config:
        from_attributes = True
