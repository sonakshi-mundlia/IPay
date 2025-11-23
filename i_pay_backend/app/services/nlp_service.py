import re
import logging
from typing import Optional, Dict, Any
from deep_translator import GoogleTranslator

try:
    import spacy
    SPACY_AVAILABLE = True
except:
    SPACY_AVAILABLE = False

try:
    from transformers import pipeline
    ZS_AVAILABLE = True
except:
    ZS_AVAILABLE = False

logger = logging.getLogger("ai_nlp_engine")

def detect_language(text: str) -> str:
    try:
        return GoogleTranslator().detect(text)
    except:
        return "en"
def translate_text(text, target_lang):
    return GoogleTranslator(source='auto', target=target_lang).translate(text)


class NLPService:
    def __init__(self):
        self.spacy_nlp = None
        self.zs_pipeline = None
        self._init_spacy()
        self._init_zero_shot()

    # Load spaCy
    def _init_spacy(self):
        if SPACY_AVAILABLE:
            try:
                self.spacy_nlp = spacy.load("en_core_web_sm")
                logger.info("spaCy loaded")
            except Exception as e:
                logger.warning("spaCy init failed: %s", e)
        else:
            logger.info("spaCy not available")

    # Load zero-shot model
    def _init_zero_shot(self):
        if ZS_AVAILABLE:
            try:
                self.zs_pipeline = pipeline("zero-shot-classification",
                                            model="facebook/bart-large-mnli")
                logger.info("Zero-shot model loaded")
            except Exception as e:
                logger.warning("Zero-shot init failed: %s", e)
        else:
            logger.info("Transformers not available")

    def extract_amount(self, text: str) -> Optional[float]:
        text = (text or "").replace(",", "")
        match = re.search(r"(?:rs|₹|inr)?\s*([0-9]+(?:\.[0-9]{1,2})?)",
                          text, flags=re.IGNORECASE)
        if match:
            try:
                return float(match.group(1))
            except:
                return None
        return None

    def extract_receiver(self, text: str) -> Optional[str]:
        text = text or ""

        if self.spacy_nlp:
            try:
                doc = self.spacy_nlp(text)
                for ent in doc.ents:
                    if ent.label_ == "PERSON":
                        return ent.text
            except:
                pass

        match = re.search(r"(?:to|for)\s+([A-Za-z][A-Za-z0-9_\- ]{0,30})",
                          text, flags=re.IGNORECASE)
        if match:
            return match.group(1).strip().split()[0]
        return None

    def detect_intent(self, text: str) -> str:
        t = (text or "").lower()

        if any(k in t for k in ("send money", "send", "transfer", "pay")):
            return "send_money"

        if any(k in t for k in ("balance", "account balance", "how much")):
            return "check_balance"

        if any(k in t for k in ("history", "transactions", "transaction history", "last")):
            return "transaction_history"

        if any(k in t for k in ("add account", "link account", "connect account")):
            return "add_account"

        if "help" in t:
            return "help"

        if self.zs_pipeline:
            labels = ["send_money", "check_balance", "transaction_history",
                      "add_account", "help", "unknown"]
            try:
                out = self.zs_pipeline(text, labels, multi_label=False)
                return out["labels"][0]
            except:
                pass

        return "unknown"

    def parse(self, text: str) -> Dict[str, Any]:
        lang = detect_language(text)
        intent = self.detect_intent(text)
        amount = self.extract_amount(text)
        receiver = self.extract_receiver(text)

        return {
            "intent": intent,
            "amount": amount,
            "receiver": receiver,
            "lang": lang,
            "raw": text
        }

    def generate_response(self, user_id: str, parsed: Dict[str, Any], backend) -> Dict[str, Any]:
        intent = parsed["intent"]
        amount = parsed["amount"]
        receiver = parsed["receiver"]
        lang = parsed["lang"]

        def tr(msg):
            return translate_text(msg, lang)

        if intent == "check_balance":
            balance = backend.get_user_balance(user_id)
            speech = tr(f"Your current account balance is {int(balance)} rupees.")
            return {"speech": speech, "navigate": None, "success": True,
                    "extra": {"balance": balance}}

        if intent == "send_money":
            if receiver is None or amount is None:
                speech = tr("Opening transaction page. Please enter receiver name, amount and your PIN.")
                return {"speech": speech, "navigate": "transaction_page",
                        "success": False, "extra": {}}

            ok = backend.process_send_money(user_id, receiver, amount)
            if ok:
                speech = tr(f"Transaction of {int(amount)} rupees to {receiver} completed successfully.")
                return {"speech": speech, "navigate": None, "success": True, "extra": {}}
            else:
                speech = tr("Transaction failed. Please try again later.")
                return {"speech": speech, "navigate": None, "success": False, "extra": {}}

        if intent == "transaction_history":
            rec = backend.get_user_transactions(user_id, limit=5)
            if not rec:
                speech = tr("You have no recent transactions.")
            else:
                short = "; ".join(rec)
                speech = tr(f"Your last transactions are: {short}.")
            return {"speech": speech, "navigate": "history_page", "success": True,
                    "extra": {"records": rec}}

        if intent == "add_account":
            speech = tr("Opening add account page. Please enter your bank account details.")
            return {"speech": speech, "navigate": "add_account_page", "success": True, "extra": {}}

        if intent == "help":
            speech = tr(
                "I can help you check balance, send money, show transaction history, or add a bank account."
            )
            return {"speech": speech, "navigate": None, "success": True, "extra": {}}

        speech = tr("Sorry, I didn't understand that. Can you repeat?")
        return {"speech": speech, "navigate": None, "success": False, "extra": {}}
