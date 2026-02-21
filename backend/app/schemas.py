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
    category: str | None = None  # Optional - will be predicted by ML if not provided

class ExpenseUpdate(BaseModel):
    amount: float | None = None
    description: str | None = None
    category: str | None = None

class ExpenseResponse(BaseModel):
    id: int
    amount: float
    description: str
    category: str
    user_id: int

    model_config = {
        "from_attributes": True   # <-- Pydantic v2 replacement for orm_mode
    }

class MonthlySummary(BaseModel):
    month: str
    year: int
    total_expenses: float
    categories: dict[str, float]  # category -> amount