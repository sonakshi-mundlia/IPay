from typing import List
from sqlalchemy.orm import Session
from ..models.help_model import FAQ
from ..services.nlp_service import NLPService

nlp_service = NLPService()

class HelpService:

    @staticmethod
    def get_faqs(db: Session) -> List[FAQ]:
        """Fetch all FAQs from DB"""
        return db.query(FAQ).all()

    @staticmethod
    def answer_question(db: Session, user_id: int, question: str) -> str:
        """
        Generate answer to user's question using NLP service.
        Accepts user_id to fetch user-specific data like balance.
        """
        parsed = nlp_service.parse(question)
        intent = parsed.get("intent")
        amount = parsed.get("amount")
        receiver = parsed.get("receiver")

        from ..models.account_model import Account

        # SEND MONEY
        if intent == "send_money":
            if receiver and amount:
                return f"To send {amount} rupees to {receiver}, go to Transactions and confirm."
            return "To send money, go to Transactions, enter receiver and amount, then confirm."

        # CHECK BALANCE
        elif intent == "check_balance":
            account = db.query(Account).filter(Account.user_id == user_id).first()
            if account:
                return f"Your current balance is {account.balance} rupees."
            return "No account found. Please add a bank account first."

        # TRANSACTION HISTORY
        elif intent == "transaction_history":
            return "You can view your recent transactions in the Transactions screen."

        # ADD ACCOUNT
        elif intent == "add_account":
            return "To add a bank account, go to Accounts and tap the '+' button."

        # CIBIL SCORE
        elif intent == "cibil_score":
            return "You can check your CIBIL score from the CIBIL Score screen."

        # LOAN APPLY
        elif intent == "loan_apply":
            return "To apply for a loan, go to the Loans section and follow the instructions."

        # BILL PAY
        elif intent == "bill_pay":
            return "You can pay your bills using the Bill Payment section."

        # BANK TRANSFER
        elif intent == "bank_transfer":
            return "To transfer money to another bank, use the Bank Transfer option in Transactions."

        # RECHARGE PAY
        elif intent == "recharge_pay":
            return "To recharge your mobile or DTH, go to the Recharge section and follow the prompts."

        # HELP
        elif intent == "help":
            return (
                "You can ask about sending money, checking balance, viewing transaction history, "
                "adding accounts, checking CIBIL score, applying for loans, paying bills, "
                "transferring to banks, or mobile/DTH recharge."
            )

        # UNKNOWN
        else:
            return "Sorry, I could not understand your question. Please try again."
