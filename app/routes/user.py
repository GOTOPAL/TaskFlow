from fastapi import APIRouter,Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.auth.dependencies import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.user import UserCreate, UserInfo, UserLogin,UserOut
from app.services.user import create_user,user_login,get_me
from fastapi.security import OAuth2PasswordRequestForm
from app.crud.user import delete_user

router = APIRouter()

@router.post("/auth/register",response_model=UserOut,tags=["Auth"])
async def register(user_data:UserCreate,db:AsyncSession = Depends(get_db)):
    return await create_user(db,user_data)

@router.post("/auth/login",tags=["Auth"])
async def login(form_data: OAuth2PasswordRequestForm = Depends(),db:AsyncSession = Depends(get_db)):
    return await user_login(db,form_data)

@router.get("/user/me",response_model=UserInfo,tags=["User"])
async def me(db:AsyncSession=Depends(get_db),current_user:User=Depends(get_current_user)):
    return await get_me(db,current_user.id)

@router.delete("/user/delete",tags=["User"])
async def delete(db:AsyncSession=Depends(get_db),current_user:User=Depends(get_current_user)):
    return await delete_user(db,current_user.id)