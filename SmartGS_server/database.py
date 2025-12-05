from pymongo import MongoClient
from dotenv import load_dotenv
import os

load_dotenv()

client = MongoClient(os.getenv("MONGO_URI"))
db = client.smartGS

products = db["products"]
users = db["users"]
carts = db["carts"]
orders = db["orders"]