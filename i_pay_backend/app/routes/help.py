from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from ..schemas.help_schema import FAQResponse, HelpRequest, HelpAnswer
from ..services.help_service import HelpService
from ..database import get_db

router = APIRouter(prefix="/help", tags=["Help"])
help_service = HelpService()

@router.get("/faqs", response_model=List[FAQResponse])
def get_faqs(db: Session = Depends(get_db)):
    return help_service.get_faqs(db)

@router.post("/ask", response_model=HelpAnswer)
def ask_question(request: HelpRequest, db: Session = Depends(get_db)):
    answer = help_service.answer_question(db, request.question)
    return HelpAnswer(answer=answer)
