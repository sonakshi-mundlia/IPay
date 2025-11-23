from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..services.analytics_service import AnalyticsService
from ..schemas.analytics_schema import AnalyticsResponse
from ..database import get_db
from ..dependencies import get_current_user

router = APIRouter(prefix="/analytics", tags=["Analytics"])

@router.get("/summary", response_model=AnalyticsResponse)
def get_analytics(db: Session = Depends(get_db), current_user = Depends(get_current_user)):
    total_sent = AnalyticsService.get_total_sent(db, current_user.id)
    total_received = AnalyticsService.get_total_received(db, current_user.id)
    num_transactions = AnalyticsService.get_transaction_count(db, current_user.id)
    spending_info = AnalyticsService.get_spending_category(db, current_user.id)

    return AnalyticsResponse(
        total_sent=total_sent,
        total_received=total_received,
        num_transactions=num_transactions,
        category=spending_info.get("category"),
        description=spending_info.get("description")
    )
