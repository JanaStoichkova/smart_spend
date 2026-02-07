from fastapi import APIRouter,Depends
from sqlalchemy.orm import Session
from app.schemas import ExpenseCreate, ExpenseResponse
from app.database import SessionLocal
from app import models
from app.utils.dependencies import get_current_user, get_db
router = APIRouter()

@router.get("/")
def get_expenses(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    expenses = db.query(models.Expense).filter(
        models.Expense.user_id == current_user.id
    ).all()

    return expenses


@router.post("/", response_model=ExpenseResponse)
def create_expense(
    expense_data: ExpenseCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    expense = models.Expense(
        **expense_data.dict(),
        user_id=current_user.id
    )
    db.add(expense)
    db.commit()
    db.refresh(expense)
    return expense
