from fastapi import APIRouter, HTTPException
from database import users
from models.user import UserCreate, UserLogin
from utils.password_hash import hash_password, verify_password
from utils.jwt_handler import create_token

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/signup")
def signup(user: UserCreate):
    if users.find_one({"username": user.username}):
        raise HTTPException(400, "Username already exists")

    if users.find_one({"email": user.email}):
        raise HTTPException(400, "Email already registered")
    
    if users.find_one({"phone": user.phone}):
        raise HTTPException(400, "Phone number already registered")

    users.insert_one({
        "username": user.username,
        "email": user.email,
        "phone": user.phone,
        "password": hash_password(user.password)
    })

    return {"message": "Signup successful!"}

@router.post("/login")
def login(user: UserLogin):
    db_user = users.find_one({"username": user.username})
    if not db_user:
        raise HTTPException(401, "Invalid username or password")

    if not verify_password(user.password, db_user["password"]):
        raise HTTPException(401, "Invalid username or password")

    token = create_token({"username": user.username})

    return {
        "message": "Login successful",
        "token": token
    }