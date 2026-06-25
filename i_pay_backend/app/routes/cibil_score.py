from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from ..database import get_db
from ..schemas.cibil_score_schema import CibilResponse
from ..services.cibil_score_service import CibilService
from ..models.account_model import Account
from .auth import get_current_user
from datetime import datetime
from ..models.user_model import User

router = APIRouter()

@router.get("/cibil/ai-score", response_model=CibilResponse)
def get_cibil_score_live(
        account_id: int = Query(..., description="Selected account ID"),
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Generate AI-based CIBIL score for a selected account.
    """

    # ✅ 1. Validate account belongs to logged-in user
    account = (
        db.query(Account)
        .filter(
            Account.id == account_id,
            Account.user_id == current_user.id
        )
        .first()
    )

    if not account:
        raise HTTPException(
            status_code=404,
            detail="Account not found or does not belong to user"
        )

    # ✅ 2. Generate CIBIL for THIS account
    ai_result = CibilService.get_score(db, account.id)

    # ✅ 3. Return account-specific CIBIL response
    return CibilResponse(
        score=ai_result["score"],
        category=ai_result["category"],
        explanation=ai_result["explanation"],
        calculation=ai_result.get("calculation", ""),
        pros=ai_result["pros"],
        cons=ai_result["cons"],
        help=ai_result["help"],
        created_at=datetime.utcnow()
    )
