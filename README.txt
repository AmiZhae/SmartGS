================================================================================
                            SMART GROCERY
                  Full-Stack E-Commerce Mobile Application
================================================================================

PROJECT OVERVIEW
================================================================================

Smart Grocery is a complete full-stack mobile grocery shopping application 
built with Flutter (frontend) and FastAPI (backend). The application provides 
a seamless shopping experience with real-time cart management, secure payment 
processing via Stripe, and comprehensive order tracking.

Key Features:
- User authentication with JWT tokens
- Product browsing by category
- Real-time product search
- Shopping cart management
- Stripe payment integration
- Order history tracking
- User profile management

================================================================================
TECHNOLOGY STACK
================================================================================

Frontend:
- Flutter 3.x (Dart)
- Provider State Management
- Stripe Flutter SDK
- SharedPreferences for local storage
- HTTP package for API calls

Backend:
- FastAPI (Python 3.9+)
- MongoDB for database
- JWT for authentication
- bcrypt for password hashing
- Stripe Python SDK for payments

External Services:
- Stripe Payment Gateway
- MongoDB Database

================================================================================
INSTALLATION & SETUP
================================================================================

1. BACKEND SETUP
--------------------------------------------------------------------------------

Step 1: Install Python Dependencies
pip install -r requirements.txt

Step 2: Setup MongoDB
- Install MongoDB from https://www.mongodb.com/try/download/community
- Start MongoDB service:
  - Windows: net start MongoDB
  - macOS/Linux: sudo systemctl start mongod

Step 3: Configure Environment Variables
Create a .env file in the backend directory:

STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
MONGODB_URI=mongodb://localhost:27017
DATABASE_NAME=smartGS

Step 4: Start the Backend Server
uvicorn main:app --reload

The server will start at http://localhost:8000


2. FRONTEND SETUP
--------------------------------------------------------------------------------

Step 1: Install Flutter Dependencies
flutter pub get

Step 2: Configure API Base URL
Edit lib/services/api_service.dart:
static const String baseUrl = 'http://10.0.2.2:8000';  // For Android Emulator
// Or use 'http://localhost:8000' for iOS Simulator

Step 3: Configure Stripe Publishable Key
Edit lib/main.dart:
Stripe.publishableKey = 'pk_test_your_stripe_publishable_key_here';

Step 4: Run the Flutter App
flutter run

Or select your device/emulator in your IDE and run.

================================================================================
DATABASE SCHEMA
================================================================================

MongoDB Collections:

1. users
   {
     "_id": ObjectId,
     "username": String (unique),
     "email": String (unique),
     "phone": String (unique),
     "password": String (hashed with bcrypt)
   }

2. products
   {
     "_id": ObjectId,
     "id": Integer,
     "name": String,
     "price": Float,
     "category": String,
     "image": String
   }

3. carts
   {
     "_id": ObjectId,
     "username": String,
     "product_id": Integer,
     "quantity": Integer
   }

4. orders
   {
     "_id": ObjectId,
     "username": String,
     "items": [
       {
         "product_id": Integer,
         "product_name": String,
         "quantity": Integer,
         "price": Float,
         "image": String
       }
     ],
     "total_amount": Float,
     "status": String,
     "payment_intent_id": String,
     "timestamp": DateTime
   }

================================================================================
API ENDPOINTS
================================================================================

Base URL: http://localhost:8000

Authentication:
- POST   /auth/signup              Create new user account
- POST   /auth/login               Login and get JWT token

Profile Management:
- GET    /profile/me               Get user profile (requires auth)
- PUT    /profile/update           Update user profile (requires auth)
- PUT    /profile/change-password  Change password (requires auth)

Product Management:
- GET    /products/                Get all products
- GET    /products/{category}      Get products by category

Shopping Cart:
- POST   /cart/add                 Add item to cart (requires auth)
- GET    /cart/                    Get cart items (requires auth)
- PUT    /cart/update              Update cart item quantity (requires auth)
- DELETE /cart/delete/{product_id} Remove item from cart (requires auth)

Payment:
- POST   /payment/create-payment-intent  Create Stripe payment intent

Orders:
- POST   /order/checkout           Create order after payment (requires auth)
- GET    /order/history            Get user order history (requires auth)

================================================================================
AUTHENTICATION
================================================================================

The application uses JWT (JSON Web Tokens) for authentication.

Flow:
1. User signs up or logs in
2. Server validates credentials and returns JWT token
3. Client stores token in SharedPreferences
4. Client includes token in Authorization header for protected routes:
   Authorization: Bearer <token>

Token Details:
- Algorithm: HS256
- Expiration: 5 hours
- Payload: username, expiration time

================================================================================
PAYMENT INTEGRATION
================================================================================

The application integrates with Stripe for secure payment processing.

Payment Flow:
1. User adds items to cart and proceeds to checkout
2. Client sends payment request to backend
3. Backend creates Stripe Payment Intent
4. Backend returns client_secret to frontend
5. Frontend displays Stripe payment sheet
6. User enters card details
7. Stripe processes payment
8. On success, order is created with payment_intent_id
9. Cart is cleared automatically

Test Card Details:
- Card Number: 4242 4242 4242 4242
- Expiry: Any future date (e.g., 12/34)
- CVC: Any 3 digits (e.g., 123)
- ZIP: Any 5 digits (e.g., 12345)

================================================================================
RUNNING THE APPLICATION
================================================================================

Development Mode:

1. Start MongoDB:
   mongod

2. Start Backend Server:
   cd backend
   uvicorn main:app --reload

3. Start Flutter App:
   cd frontend
   flutter run

The app will be available on your connected device/emulator.

