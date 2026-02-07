from pydantic import BaseModel
from datetime import datetime

class UserCreate(BaseModel):#signup
    username: str
    password: str
class UserLogin(BaseModel):#login
    username: str
    password: str

class UserOut(BaseModel):
    id: int
    username: str

    class Config:
        orm_mode = True

class ExpenseCreate(BaseModel):
    amount: float
    description: str
    category: str

class ExpenseResponse(BaseModel):
    id: int
    amount: float
    description: str
    category: str
    user_id: int

    model_config = {
        "from_attributes": True   # <-- Pydantic v2 replacement for orm_mode
    }