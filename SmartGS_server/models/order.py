from pydantic import BaseModel
from typing import List, Optional

class OrderItem(BaseModel):
    product_id: int
    quantity: int
    price: Optional[float] = None  
    product_name: Optional[str] = None  

class Order(BaseModel):
    items: List[OrderItem]