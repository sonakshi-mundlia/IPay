from sqlalchemy.orm import Session
from ..models.transaction_model import Transaction
from ..models.account_model import Account

class AnalyticsService:

    @staticmethod
    def get_total_sent(db: Session, user_id: int) -> float:
        total = db.query(Transaction) \
            .join(Account, Transaction.from_account_id == Account.id) \
            .filter(Account.user_id == user_id) \
            .with_entities(Transaction.amount).all()
        return sum([amt[0] for amt in total])

    @staticmethod
    def get_total_received(db: Session, user_id: int) -> float:
        total = db.query(Transaction) \
            .join(Account, Transaction.to_account_id == Account.id) \
            .filter(Account.user_id == user_id) \
            .with_entities(Transaction.amount).all()
        return sum([amt[0] for amt in total])

    @staticmethod
    def get_transaction_count(db: Session, user_id: int) -> int:
        count = db.query(Transaction) \
            .join(Account, Transaction.from_account_id == Account.id) \
            .filter(Account.user_id == user_id).count()
        return count

    @staticmethod
    def get_spending_category(db: Session, user_id: int) -> dict:
        transactions = db.query(Transaction) \
            .join(Account, Transaction.from_account_id == Account.id) \
            .filter(Account.user_id == user_id).all()

        if not transactions:
            return {"category": None, "description": "No transactions yet"}

        category_sums = {}
        for t in transactions:
            cat = t.category or "Others"
            category_sums[cat] = category_sums.get(cat, 0) + t.amount

        top_category = max(category_sums, key=category_sums.get)
        description = f"You spend most on {top_category.lower()}."

        return {"category": top_category, "description": description}
