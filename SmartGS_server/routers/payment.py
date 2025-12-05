from fastapi import APIRouter, HTTPException, Depends
from dotenv import load_dotenv
import stripe
import os

from routers.cart import get_current_user
from models.payment import PaymentIntentRequest, PaymentIntentResponse

load_dotenv()

stripe.api_key = os.getenv("STRIPE_SECRET_KEY")

if not stripe.api_key:
    raise Exception("❌ STRIPE_SECRET_KEY not found in .env")

router = APIRouter(prefix="/payment", tags=["Payment"])

@router.post("/create-payment-intent", response_model=PaymentIntentResponse)
async def create_payment_intent(
    request: PaymentIntentRequest,
    username: str = Depends(get_current_user)
):
    try:
        amount_in_cents = int(request.amount * 100)

        payment_intent = stripe.PaymentIntent.create(
            amount=amount_in_cents,
            currency="usd",
            automatic_payment_methods={"enabled": True},
            metadata={
                "username": username,
                "items_count": len(request.items)
            }
        )

        return PaymentIntentResponse(
            client_secret=payment_intent.client_secret,
            payment_intent_id=payment_intent.id
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
