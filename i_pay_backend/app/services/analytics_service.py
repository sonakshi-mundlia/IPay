from sqlalchemy.orm import Session
from sqlalchemy import or_
from collections import defaultdict
from datetime import datetime
from ..models.transaction_model import Transaction
from ..schemas.analytics_schema import AnalyticsResponse, FraudAlert, TransactionPattern

class AnalyticsService:
    def __init__(self, db: Session):
        self.db = db

    def fetch_account_transactions(
            self,
            account_id: int,
            start_date: datetime = None,
            end_date: datetime = None
    ):
        """
        Fetch all transactions for a specific account within an optional date range.
        """
        query = self.db.query(Transaction).filter(
            or_(
                Transaction.from_account_id == account_id,
                Transaction.to_account_id == account_id
            )
        )

        if start_date:
            query = query.filter(Transaction.timestamp >= start_date)
        if end_date:
            query = query.filter(Transaction.timestamp <= end_date)

        return query.all()

    def compute_cash_flow(self, transactions, account_id: int):
        """
        Calculate total income, expense, and net cash flow for the account.
        """
        income = sum(t.amount for t in transactions if t.to_account_id == account_id)
        expense = sum(t.amount for t in transactions if t.from_account_id == account_id)
        net_flow = income - expense
        return income, expense, net_flow

    def categorize_transactions(self, transactions, account_id: int):
        """
        Summarize transactions by category.
        """
        category_summary = defaultdict(float)
        for t in transactions:
            if t.to_account_id == account_id:
                category_summary[t.category] += t.amount
            else:
                category_summary[t.category] -= t.amount
        return dict(category_summary)

    def detect_patterns(self, transactions, account_id: int):
        """
        Identify patterns of income and expenses by type and category.
        """
        patterns = defaultdict(list)
        for t in transactions:
            t_type = "income" if t.to_account_id == account_id else "expense"
            patterns[t_type].append(TransactionPattern(
                category=t.category,
                amount=t.amount,
                date=t.timestamp
            ))
        return dict(patterns)

    def financial_indicators(self, transactions, account_id: int):
        """
        Compute key financial health indicators: debt-to-income ratio, savings rate, average daily balance.
        """
        total_income = sum(t.amount for t in transactions if t.to_account_id == account_id)
        total_expense = sum(t.amount for t in transactions if t.from_account_id == account_id)
        debt = sum(t.amount for t in transactions if t.category.lower() == "debt")
        savings = total_income - total_expense

        debt_to_income_ratio = debt / total_income if total_income else None
        savings_rate = savings / total_income if total_income else None
        avg_daily_balance = savings / max(1, len(transactions))  # avoid division by zero

        return {
            "debt_to_income_ratio": debt_to_income_ratio,
            "savings_rate": savings_rate,
            "avg_daily_balance": avg_daily_balance
        }

    def fraud_detection(self, transactions, threshold: float = 10000.0, account_id: int = None):
        """
        Detect potentially fraudulent transactions exceeding a specified threshold.
        """
        alerts = []
        for t in transactions:
            if abs(t.amount) >= threshold:
                t_type = "income" if t.to_account_id == account_id else "expense"
                alerts.append(FraudAlert(
                    id=t.id,
                    amount=t.amount,
                    category=t.category,
                    type=t_type,
                    date=t.timestamp,
                    message="Transaction exceeds threshold"
                ))
        return alerts

    def generate_report(
            self,
            account_id: int,
            start_date: datetime = None,
            end_date: datetime = None
    ) -> AnalyticsResponse:
        """
        Generate a full analytics report for a given account within an optional date range.
        """
        transactions = self.fetch_account_transactions(account_id, start_date, end_date)
        total_income, total_expense, net_cash_flow = self.compute_cash_flow(transactions, account_id)
        category_summary = self.categorize_transactions(transactions, account_id)
        patterns = self.detect_patterns(transactions, account_id)
        indicators = self.financial_indicators(transactions, account_id)
        fraud_alerts = self.fraud_detection(transactions, account_id=account_id)

        return AnalyticsResponse(
            total_income=total_income,
            total_expense=total_expense,
            net_cash_flow=net_cash_flow,
            category_summary=category_summary,
            patterns=patterns,
            debt_to_income_ratio=indicators["debt_to_income_ratio"],
            savings_rate=indicators["savings_rate"],
            avg_daily_balance=indicators["avg_daily_balance"],
            fraud_alerts=fraud_alerts
        )
