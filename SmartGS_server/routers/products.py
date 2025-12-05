from fastapi import APIRouter, HTTPException
from database import products

router = APIRouter(prefix="/products",tags=["Products"])

@router.get("/")
def get_all_products():
    items = list(products.find({}, {"_id": 0}))
    return {"count": len(items), "products": items}

@router.get("/{category}")
def get_products_by_category(category: str):
    items = list(products.find(
        {"category": {"$regex": f"^{category}$", "$options": "i"}},
        {"_id": 0}
    ))

    if not items:
        raise HTTPException(404, "Category not found")

    return {"category": category, "count": len(items), "products": items}