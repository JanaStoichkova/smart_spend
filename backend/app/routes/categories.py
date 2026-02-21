from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.utils.dependencies import get_db
from app import models
from app.utils.dependencies import get_current_user

router = APIRouter(tags=["Categories"])


@router.get("/")
def get_categories(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    categories = (
        db.query(models.Category)
        .filter(models.Category.user_id == current_user.id)
        .all()
    )

    return [
        {
            "id": category.id,
            "name": category.name
        }
        for category in categories
    ]
