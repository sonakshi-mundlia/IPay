from typing import List
from sqlalchemy.orm import Session
from ..models.help_model import FAQ
from ..services.nlp_service import NLPService

nlp_service = NLPService()

class HelpService:

    @staticmethod
    def get_faqs(db: Session) -> List[FAQ]:
        return db.query(FAQ).all()

    @staticmethod
    def answer_question(db: Session, question: str) -> str:
        parsed = nlp_service.parse(question)
        intent = parsed.get("intent")

        if intent == "send_money":
            return "To send money, go to Transactions, enter receiver and amount, then confirm."
        elif intent == "check_balance":
            from ..models.account_model import Account
            account = db.query(Account).first()
            if account:
                return f"Your balance is {account.balance} rupees."
            return "No account found."
        elif intent == "help":
            return "You can ask about sending money, checking balance, adding accounts, or transaction history."
        else:
            return "Sorry, I could not understand your question. Please try again."
