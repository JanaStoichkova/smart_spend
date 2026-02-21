from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime
from collections import defaultdict

from app.schemas import ExpenseCreate, ExpenseUpdate, ExpenseResponse, MonthlySummary
from app import models
from app.utils.dependencies import get_current_user, get_db
from app.utils.nlp import predict_category

router = APIRouter()


@router.get("/", response_model=list[ExpenseResponse])
def get_expenses(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    expenses = (
        db.query(models.Expense, models.Category)
        .join(models.Category)
        .filter(models.Expense.user_id == current_user.id)
        .all()
    )

    return [
        {
            "id": expense.id,
            "amount": expense.amount,
            "description": expense.description,
            "category": category.name,
            "user_id": expense.user_id,
        }
        for expense, category in expenses
    ]


@router.post("/", response_model=ExpenseResponse)
def create_expense(
    expense_data: ExpenseCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    # Use ML prediction if category not provided
    category_name = expense_data.category
    if category_name is None or category_name.strip() == "":
        try:
            category_name = predict_category(expense_data.description)
        except Exception:
            category_name = "Uncategorized"
    
    category = db.query(models.Category).filter(
        models.Category.name == category_name,
        models.Category.user_id == current_user.id
    ).first()

    if not category:
        category = models.Category(
            name=category_name,
            user_id=current_user.id
        )
        db.add(category)
        db.commit()
        db.refresh(category)

    expense = models.Expense(
        amount=expense_data.amount,
        description=expense_data.description,
        category_id=category.id,
        user_id=current_user.id
    )

    db.add(expense)
    db.commit()
    db.refresh(expense)

    return {
        "id": expense.id,
        "amount": expense.amount,
        "description": expense.description,
        "category": category.name,
        "user_id": expense.user_id
    }


@router.get("/{expense_id}", response_model=ExpenseResponse)
def get_expense(
    expense_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    expense = (
        db.query(models.Expense, models.Category)
        .join(models.Category)
        .filter(
            models.Expense.id == expense_id,
            models.Expense.user_id == current_user.id
        )
        .first()
    )
    
    if not expense:
        raise HTTPException(status_code=404, detail="Expense not found")
    
    expense, category = expense
    return {
        "id": expense.id,
        "amount": expense.amount,
        "description": expense.description,
        "category": category.name,
        "user_id": expense.user_id
    }


@router.put("/{expense_id}", response_model=ExpenseResponse)
def update_expense(
    expense_id: int,
    expense_update: ExpenseUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    expense = db.query(models.Expense).filter(
        models.Expense.id == expense_id,
        models.Expense.user_id == current_user.id
    ).first()
    
    if not expense:
        raise HTTPException(status_code=404, detail="Expense not found")
    
    category = None
    
    if expense_update.category is not None:
        category = db.query(models.Category).filter(
            models.Category.name == expense_update.category,
            models.Category.user_id == current_user.id
        ).first()
        
        if not category:
            category = models.Category(
                name=expense_update.category,
                user_id=current_user.id
            )
            db.add(category)
            db.commit()
            db.refresh(category)
    
    update_data = expense_update.dict(exclude_unset=True)
    if "amount" in update_data:
        expense.amount = update_data["amount"]
    if "description" in update_data:
        expense.description = update_data["description"]
    if category:
        expense.category_id = category.id
    
    db.commit()
    db.refresh(expense)
    
    if category:
        category_name = category.name
    else:
        category_obj = db.query(models.Category).filter(models.Category.id == expense.category_id).first()
        category_name = category_obj.name if category_obj else "Unknown"
    
    return {
        "id": expense.id,
        "amount": expense.amount,
        "description": expense.description,
        "category": category_name,
        "user_id": expense.user_id
    }


@router.delete("/{expense_id}")
def delete_expense(
    expense_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    expense = db.query(models.Expense).filter(
        models.Expense.id == expense_id,
        models.Expense.user_id == current_user.id
    ).first()
    
    if not expense:
        raise HTTPException(status_code=404, detail="Expense not found")
    
    db.delete(expense)
    db.commit()
    
    return {"message": "Expense deleted successfully"}


@router.get("/summary/{year}/{month}", response_model=MonthlySummary)
def get_monthly_summary(
    year: int,
    month: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    if month < 1 or month > 12:
        raise HTTPException(status_code=400, detail="Invalid month (1-12)")
    
    # Get start and end of month
    start_date = datetime(year, month, 1)
    if month == 12:
        end_date = datetime(year + 1, 1, 1)
    else:
        end_date = datetime(year, month + 1, 1)
    
    # Query expenses for the month
    expenses = (
        db.query(models.Expense, models.Category)
        .join(models.Category)
        .filter(
            models.Expense.user_id == current_user.id,
            models.Expense.date >= start_date,
            models.Expense.date < end_date
        )
        .all()
    )
    
    # Calculate totals by category
    category_totals = defaultdict(float)
    total_expenses = 0.0
    
    for expense, category in expenses:
        category_totals[category.name] += expense.amount
        total_expenses += expense.amount
    
    # Get month name
    month_names = ["", "January", "February", "March", "April", "May", "June",
                   "July", "August", "September", "October", "November", "December"]
    
    return {
        "month": month_names[month],
        "year": year,
        "total_expenses": round(total_expenses, 2),
        "categories": dict(category_totals)
    }
