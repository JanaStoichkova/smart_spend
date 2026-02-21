from fastapi import APIRouter, Depends
from pydantic import BaseModel
from app.utils.nlp import predict_category

router = APIRouter()

# Request schema
class PredictRequest(BaseModel):
    description: str

# Response schema
class PredictResponse(BaseModel):
    description: str
    predicted_category: str

@router.post("/predict", response_model=PredictResponse)
def predict_expense(request: PredictRequest):
    category = predict_category(request.description)
    return {"description": request.description, "predicted_category": category}