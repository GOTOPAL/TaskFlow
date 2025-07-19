from fastapi import APIRouter,Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.schemas.user import UserCreate, UserLogin,UserOut
from app.services.user import create_user,user_login
from fastapi.security import OAuth2PasswordRequestForm

router = APIRouter(tags=["Kayıt"])

@router.post("/register",response_model=UserOut)
async def register(user_data:UserCreate,db:AsyncSession = Depends(get_db)):
    return await create_user(db,user_data)

@router.post("/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends(),db:AsyncSession = Depends(get_db)):
    return await user_login(db,form_data)