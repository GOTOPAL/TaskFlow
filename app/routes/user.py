from fastapi import APIRouter,Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.auth.dependencies import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.user import UserCreate, UserInfo, UserLogin,UserOut
from app.services.user import create_user,user_login,get_me
from fastapi.security import OAuth2PasswordRequestForm

router = APIRouter(prefix="/auth",tags=["Auth"])

@router.post("/register",response_model=UserOut)
async def register(user_data:UserCreate,db:AsyncSession = Depends(get_db)):
    return await create_user(db,user_data)

@router.post("/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends(),db:AsyncSession = Depends(get_db)):
    return await user_login(db,form_data)

@router.get("/me",response_model=UserInfo)
async def me(db:AsyncSession=Depends(get_db),current_user:User=Depends(get_current_user)):
    return await get_me(db,current_user.id)