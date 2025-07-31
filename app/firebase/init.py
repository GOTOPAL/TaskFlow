import firebase_admin
from firebase_admin import credentials

cred = credentials.Certificate("app/firebase/service_account_key.json")
firebase_app = firebase_admin.initialize_app(cred)
