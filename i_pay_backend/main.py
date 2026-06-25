from fastapi import FastAPI
from app.database import Base, engine
from fastapi.middleware.cors import CORSMiddleware
from app.routes import auth, analytics, transaction, nlp, account, help, profile,reset_pin, cibil_score, users, pin_router

Base.metadata.create_all(bind=engine)

app = FastAPI(title="iPay Backend with NLP")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, tags=["Auth"])
app.include_router(account.router, tags=["Accounts"])
app.include_router(transaction.router, tags=["Transactions"])
app.include_router(nlp.router)
app.include_router(analytics.router, tags=["Analytics"])
app.include_router(help.router, tags=["Help"])
app.include_router(profile.router, tags=["Profile"])
app.include_router(reset_pin.router, tags=["PIN"])
app.include_router(cibil_score.router)
app.include_router(users.router, tags=["Users"])
app.include_router(pin_router.router, tags=["PIN"])