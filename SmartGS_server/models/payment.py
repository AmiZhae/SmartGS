from pydantic import BaseModel
from typing import List

class PaymentIntentRequest(BaseModel):
    amount: float
    items: List[dict]

class PaymentIntentResponse(BaseModel):
    client_secret: str
    payment_intent_id: str
