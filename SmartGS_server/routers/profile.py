from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from database import users
from models.user import UpdateProfile, ChangePassword
from utils.jwt_handler import decode_token
from utils.password_hash import verify_password, hash_password

router = APIRouter(prefix="/profile", tags=["Profile"])
security = HTTPBearer()

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    try:
        payload = decode_token(token)
        username = payload.get("username")
        if not username:
            raise HTTPException(status_code=401, detail="Invalid token: no username")
        return username
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Invalid or expired token: {str(e)}")

@router.get("/me")
def get_profile(username: str = Depends(get_current_user)):
    user = users.find_one({"username": username}, {"_id": 0, "password": 0})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return {
        "username": user.get("username"),
        "email": user.get("email"),
        "phone": user.get("phone", "")
    }

@router.put("/update")
def update_profile(profile: UpdateProfile, username: str = Depends(get_current_user)):
    user = users.find_one({"username": username})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if profile.email and profile.email != user.get("email"):
        existing_email = users.find_one({"email": profile.email, "username": {"$ne": username}})
        if existing_email:
            raise HTTPException(status_code=400, detail="Email already in use")
    
    update_data = {}
    if profile.email:
        update_data["email"] = profile.email
    if profile.phone is not None:
        update_data["phone"] = profile.phone
    
    if update_data:
        users.update_one({"username": username}, {"$set": update_data})
    
    return {
        "message": "Profile updated successfully",
        "username": username
    }

@router.put("/change-password")
def change_password(data: ChangePassword, username: str = Depends(get_current_user)):
    try:
        user = users.find_one({"username": username})
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        if not verify_password(data.current_password, user["password"]):
            raise HTTPException(status_code=400, detail="Current password is incorrect")
        
        if len(data.new_password) < 6:
            raise HTTPException(status_code=400, detail="New password must be at least 6 characters")
        
        if data.new_password == data.current_password:
            raise HTTPException(status_code=400, detail="New password must be different from current password")
        
        new_hashed_password = hash_password(data.new_password)
        result = users.update_one(
            {"username": username},
            {"$set": {"password": new_hashed_password}}
        )
        
        if result.modified_count == 0:
            raise HTTPException(status_code=500, detail="Failed to update password")
        
        return {"message": "Password changed successfully"}
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error changing password: {str(e)}")