import os
import json
from datetime import datetime
from sqlalchemy.orm import Session
from groq import Groq

from ..models.account_model import Account
from ..models.transaction_model import Transaction

client = Groq(api_key=os.getenv("GROQ_API_KEY"))


class CibilService:

    @staticmethod
    def get_score(db: Session, account_id: int) -> dict:
        account = db.query(Account).filter(Account.id == account_id).first()
        if not account:
            raise ValueError("Account not found")

        transactions = (
            db.query(Transaction)
            .filter(Transaction.from_account_id == account.id)
            .order_by(Transaction.timestamp.desc())
            .limit(10)
            .all()
        )

        total_spent = sum(t.amount for t in transactions)
        available = account.balance + total_spent
        utilization = int((total_spent / available) * 100) if available > 0 else 0

        # 🔹 Pure scoring logic (NO TEXT)
        if utilization < 30:
            score, category, risk = 780, "Excellent", "Very Low"
        elif utilization < 50:
            score, category, risk = 720, "Very Good", "Low"
        elif utilization < 70:
            score, category, risk = 650, "Good", "Moderate"
        else:
            score, category, risk = 580, "Fair", "High"

        return CibilService._generate_ai_report(score, category, risk)

    # ------------------------------------------------------

    @staticmethod
    def _word_count(text: str) -> int:
        return len(text.split())

    @staticmethod
    def _confidence_score(score: int, risk: str) -> int:
        base = score / 900
        risk_factor = {
            "Very Low": 1.0,
            "Low": 0.9,
            "Moderate": 0.75,
            "High": 0.6
        }.get(risk, 0.7)

        return int(base * risk_factor * 100)

    # ------------------------------------------------------

    @staticmethod
    def _generate_ai_report(score: int, category: str, risk: str) -> dict:
        """
        AI writes everything.
        Auto-regenerates until explanation is 50–60 words.
        """

        max_attempts = 3
        ai_data = {}

        for attempt in range(max_attempts):
            prompt = f"""
You are a senior Indian credit analyst.

Context:
- Credit Category: {category}
- Risk Level: {risk}

TASK:
Write a detailed professional credit report.

STRICT RULES:
- Explanation MUST be between 50 and 60 words
- Use behavioural analysis (not numbers)
- Do NOT mention transactions, balances, or scores
- Do NOT reuse prompt phrases
- Pros & Cons must be realistic
- Educational tone only

Return ONLY valid JSON.

JSON format:
{{
  "explanation": string,
  "pros": [string, string],
  "cons": [string, string],
  "help": {{
    "how_to_check": string,
    "how_to_improve": string
  }}
}}
"""

            response = client.chat.completions.create(
                model="llama-3.1-8b-instant",
                messages=[
                    {"role": "system", "content": "You generate deep Indian credit analysis reports."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.8,
                max_tokens=900
            )

            raw = response.choices[0].message.content.strip()
            if raw.startswith("```"):
                raw = raw.replace("```json", "").replace("```", "").strip()
            print("\n========== AI RAW RESPONSE ==========\n", raw, "\n====================================\n")

            try:
                ai_data = json.loads(raw)
            except Exception as e:
                print("JSON PARSE FAILED:", e)
                print("RAW WAS:", raw)
                continue


            explanation = ai_data.get("explanation", "")
            wc = CibilService._word_count(explanation)

            if 50 <= wc <= 60:
                break  # ✅ Acceptable output

        confidence = CibilService._confidence_score(score, risk)

        return {
            "score": score,
            "category": category,
            "confidence_score": confidence,  # ✅ NEW
            "explanation": ai_data.get("explanation"),
            "calculation": "AI-based behavioural credit risk analysis",
            "pros": ai_data.get("pros"),
            "cons": ai_data.get("cons"),
            "help": ai_data.get("help"),
            "created_at": datetime.utcnow()
        }
