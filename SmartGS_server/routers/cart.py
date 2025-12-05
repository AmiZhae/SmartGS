from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from models.cart import CartItem
from database import carts, products
from utils.jwt_handler import decode_token

router = APIRouter(prefix="/cart", tags=["Cart"])

security = HTTPBearer()

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    try:
        payload = decode_token(token)
        username = payload.get("username")
        if not username:
            raise HTTPException(status_code=401, detail="Invalid token: no username")
        return username
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    
@router.post("/add")
def add_to_cart(item: CartItem, username: str = Depends(get_current_user)):
    product = products.find_one({"id": item.product_id})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    existing = carts.find_one({"username": username, "product_id": item.product_id})
    if existing:
        carts.update_one({"_id": existing["_id"]}, {"$inc": {"quantity": item.quantity}})
    else:
        carts.insert_one({
            "username": username,
            "product_id": item.product_id,
            "quantity": item.quantity
        })
    return {"message": "Item added to cart", "username": username}

@router.get("/")
def view_cart(username: str = Depends(get_current_user)):
    items = list(carts.find({"username": username}, {"_id": 0,"username": 0}))
    return {"username": username, "cart": items}

@router.put("/update")
def update_cart(item: CartItem, username: str = Depends(get_current_user)):
    existing = carts.find_one({"username": username, "product_id": item.product_id})
    if not existing:
        raise HTTPException(status_code=404, detail="Item not found in cart")

    carts.update_one({"_id": existing["_id"]}, {"$set": {"quantity": item.quantity}})
    return {"message": "Item quantity updated", "username": username, "product_id": item.product_id, "new_quantity": item.quantity}

@router.delete("/delete/{product_id}")
def delete_cart_item(product_id: int, username: str = Depends(get_current_user)):
    existing = carts.find_one({"username": username, "product_id": product_id})
    if not existing:
        raise HTTPException(status_code=404, detail="Item not found in cart")

    carts.delete_one({"_id": existing["_id"]})
    return {"message": "Item deleted from cart", "username": username, "product_id": product_id}