from fastapi import APIRouter, Depends, HTTPException
from models.order import Order
from database import carts, orders, products
from routers.cart import get_current_user
from datetime import datetime
from bson import ObjectId

router = APIRouter(prefix="/order", tags=["Order"])

@router.post("/checkout")
def checkout(order: Order, payment_intent_id: str, username: str = Depends(get_current_user)):
    if not payment_intent_id:
        raise HTTPException(status_code=400, detail="Payment intent ID is required")
    
    enriched_items = []
    total_amount = 0.0

    for item in order.items:
        product = products.find_one({"id": item.product_id})
        if not product:
            raise HTTPException(status_code=404, detail=f"Product ID {item.product_id} not found")

        enriched_item = {
            "product_id": item.product_id,
            "product_name": item.product_name or product["name"],
            "quantity": item.quantity,
            "price": item.price or product["price"],
            "image": product.get("image", "no_image.png")
        }

        enriched_items.append(enriched_item)
        total_amount += enriched_item["price"] * item.quantity

    order_doc = {
        "username": username,
        "items": enriched_items,
        "total_amount": total_amount,
        "status": "paid",  
        "payment_intent_id": payment_intent_id,
        "timestamp": datetime.utcnow()
    }

    result = orders.insert_one(order_doc)
    order_id = str(result.inserted_id)

    carts.delete_many({"username": username})

    return {
        "message": "Order placed successfully",
        "order_id": order_id,
        "username": username,
        "total_amount": total_amount,
        "status": "paid",
        "items": enriched_items
    }

@router.get("/history")
def get_order_history(username: str = Depends(get_current_user)):
    try:
        user_orders = list(
            orders.find(
                {"username": username},
                {"_id": 1, "items": 1, "total_amount": 1, "status": 1, "timestamp": 1}
            ).sort("timestamp", -1)
        )
        
        for order in user_orders:
            order["order_id"] = str(order.pop("_id"))

        return {
            "username": username,
            "orders": user_orders,
            "count": len(user_orders)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to load orders: {str(e)}")