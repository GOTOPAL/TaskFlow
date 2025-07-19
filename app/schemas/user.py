from pydantic import BaseModel,EmailStr

class UserCreate(BaseModel):
    name: str
    surname:str
    email:EmailStr
    password:str

class UserOut(BaseModel):
    name:str
    surname:str
    email:EmailStr

class UserLogin(BaseModel):
    email:EmailStr
    password:str