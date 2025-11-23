from fastapi import FastAPI
from app.database import Base, engine
from app.routes import auth, analytics, transaction, nlp, account, help, profile

Base.metadata.create_all(bind=engine)

app = FastAPI(title="iPay Backend with NLP")

app.include_router(auth.router, prefix="/auth", tags=["Auth"])
app.include_router(account.router, prefix="/accounts", tags=["Accounts"])
app.include_router(transaction.router)
app.include_router(nlp.router)
app.include_router(analytics.router, prefix="/analytics", tags=["Analytics"])
app.include_router(help.router, prefix="/help", tags=["Help"])
app.include_router(profile.router, prefix="/profile", tags=["Profile"])