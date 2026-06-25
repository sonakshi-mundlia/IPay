import re
import logging
from typing import Optional, Dict, Any
from deep_translator import GoogleTranslator

logger = logging.getLogger("ai_nlp_engine")

# =========================
# LANGUAGE
# =========================
def detect_language(text: str) -> str:
    try:
        return GoogleTranslator().detect(text)
    except Exception:
        return "en"


def translate_text(text: str, target_lang: str) -> str:
    try:
        return GoogleTranslator(source="auto", target=target_lang).translate(text)
    except Exception:
        return text


# =========================
# NLP SERVICE
# =========================
class NLPService:

    # -------------------------
    # AMOUNT
    # -------------------------
    def extract_amount(self, text: str) -> Optional[float]:
        text = (text or "").replace(",", "")
        match = re.search(r"(?:rs|₹|inr)?\s*([0-9]+(?:\.[0-9]{1,2})?)", text, re.I)
        if match:
            return float(match.group(1))
        return None

    # -------------------------
    # PIN
    # -------------------------
    def extract_pin(self, text: str) -> Optional[str]:
        text = re.sub(r"\D", "", text or "")
        if 3 <= len(text) <= 6:
            return text
        return None

    # -------------------------
    # RECEIVER
    # -------------------------
    def extract_receiver(self, text: str) -> Optional[str]:
        match = re.search(r"(?:to|for)\s+([a-zA-Z]{3,})", text or "", re.I)
        if match:
            return match.group(1)
        return None

    # -------------------------
    # INTENT DETECTION
    # -------------------------
    def detect_intent(self, text: str) -> str:
        t = (text or "").lower().strip()

        # 🔐 PIN (highest priority)
        if self.extract_pin(t):
            return "pin"

        # 💰 BALANCE
        if any(k in t for k in [
            "balance", "balans", "ballance",
            "account balance", "check balance",
            "how much money", "how much amount",
            "kitna paisa", "kitna balance"
        ]):
            return "check_balance"

        # 👤 PROFILE
        if any(k in t for k in [
            "profile", "profil", "pro file",
            "my details", "my account",
            "account details", "user details"
        ]):
            return "profile"

        # 📜 TRANSACTIONS
        if any(k in t for k in [
            "transaction", "transactions",
            "history", "histori", "statement",
            "passbook", "past payments",
            "recent payments", "recent spends"
        ]):
            return "transaction_history"

        # 💸 SEND MONEY
        if any(k in t for k in [
            "send", "sent", "sand",
            "transfer", "trancefer",
            "pay", "payment", "paye"
        ]):
            if self.extract_amount(t):
                return "send_money"

        # 📊 CIBIL
        if any(k in t for k in [
            "cibil", "civil", "sibill", "see bill",
            "credit score", "credit skore",
            "loan score", "score check"
        ]):
            return "cibil_score"

        # 🏦 LOAN
        if any(k in t for k in [
            "loan", "lone", "advance",
            "borrow", "udhar"
        ]):
            return "loan_apply"

        # 🧾 BILL
        if any(k in t for k in [
            "bill", "bills", "bill payment",
            "electricity", "current bill",
            "water bill", "gas bill"
        ]):
            return "bill_pay"

        # 📱 RECHARGE
        if any(k in t for k in [
            "recharge", "re charge",
            "topup", "top up",
            "mobile recharge", "phone recharge"
        ]):
            return "recharge_pay"

        # 📈 ANALYTICS
        if any(k in t for k in [
            "analytics", "analysis",
            "dashboard", "dash board",
            "spending", "expenses",
            "where money went"
        ]):
            return "analytics"

        # ❓ HELP
        if any(k in t for k in [
            "help", "halp",
            "what can you do",
            "options", "menu",
            "commands"
        ]):
            return "help"

        return "unknown"

    # -------------------------
    # MAIN PARSER
    # -------------------------
    def parse(self, text: str) -> Dict[str, Any]:
        return {
            "raw": text,
            "lang": detect_language(text),
            "intent": self.detect_intent(text),
            "amount": self.extract_amount(text),
            "receiver": self.extract_receiver(text),
            "pin": self.extract_pin(text),
        }
