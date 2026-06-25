from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime
from typing import Optional

from ..database import get_db
from ..services.analytics_service import AnalyticsService
from ..schemas.analytics_schema import AnalyticsResponse
from ..dependencies import get_current_user
from ..models import User, Account

router = APIRouter(prefix="/analytics", tags=["Analytics"])

@router.get("/", response_model=AnalyticsResponse)
def get_analytics(
        account_id: int,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Generate a detailed analytics report for a specific account.

    - account_id: ID of the account to generate the report for.
    - start_date, end_date: Optional date range for transactions.
    """
    # Verify that the current user owns this account
    account = db.query(Account).filter(
        Account.id == account_id,
        Account.user_id == current_user.id
    ).first()

    if not account:
        raise HTTPException(
            status_code=404,
            detail="Account not found or not owned by user"
        )

# ✅ Instantiate AnalyticsService inside the route where db exists
    analytics_service = AnalyticsService(db)

    # Generate report
    report = analytics_service.generate_report(
        account_id=account_id,
        start_date=start_date,
        end_date=end_date
    )

    return report
