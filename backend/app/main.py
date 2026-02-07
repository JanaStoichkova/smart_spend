from fastapi import FastAPI
from fastapi.security import OAuth2PasswordBearer
from app.routes import auth, expenses, categories
from app.database import engine
from app.models import Base
Base.metadata.create_all(bind=engine)#Koga FastApi ke startne avtomatski kreira tabela ako ne postoi databazata ja kreira

app = FastAPI()

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(expenses.router, prefix="/expenses", tags=["expenses"])#Site endpoints vo expenses.py ke pochnat so /expenses
app.include_router(categories.router, prefix="/categories", tags=["categories"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")
@app.get("/")
def root():
    return {"message": "SmartSpend API is running"}