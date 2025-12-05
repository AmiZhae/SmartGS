from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers.auth import router as auth_router
from routers.profile import router as profile_router
from routers.products import router as products_router
from routers.cart import router as cart_router
from routers.order import router as order_router
from routers.payment import router as payment_router

app = FastAPI(title="Smart Grocery API", version="1.0")

@app.get("/")
def home():
    return {"message": "Welcome to Smart Grocery API!"}

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],  
    allow_headers=["*"],  
)

app.include_router(auth_router)
app.include_router(profile_router)
app.include_router(products_router)
app.include_router(cart_router)
app.include_router(order_router)
app.include_router(payment_router)