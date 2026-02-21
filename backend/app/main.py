from fastapi import FastAPI
from fastapi.security import OAuth2PasswordBearer
from fastapi.middleware.cors import CORSMiddleware
from app.routes import auth, expenses, categories,predict
from app.database import engine
from app.models import Base
Base.metadata.create_all(bind=engine)#Koga FastApi ke startne avtomatski kreira tabela ako ne postoi databazata ja kreira

app = FastAPI()

# Enable CORS for Flutter web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(expenses.router, prefix="/expenses", tags=["expenses"])#Site endpoints vo expenses.py ke pochnat so /expenses
app.include_router(categories.router, prefix="/categories", tags=["categories"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")
app.include_router(predict.router, prefix="/ml") 
@app.get("/")
def root():
    return {"message": "SmartSpend API is running"}