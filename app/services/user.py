from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.user import UserCreate,UserLogin
from app.crud.user import existing_user,get_me as get_info
from fastapi import HTTPException,status
from app.crud.user import create_user as create
from app.auth.security import verify_hashed_password
from app.auth.jwt import create_access_token


async def create_user(db:AsyncSession,user_data:UserCreate):
    existing = await existing_user(db,user_data.email)
    if existing:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,detail="Email adresine kayıtlı hesap bulunmaktadır.")
    return await create(db,user_data)

async def user_login(db:AsyncSession,form_data: OAuth2PasswordRequestForm):
    existing = await existing_user(db,form_data.username)
    if not existing:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail="Email adresine kayıtlı hesap bulunamadı.")
    pass_check = verify_hashed_password(form_data.password,existing.hashed_password)
    if not pass_check:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,detail="Şifre yanlış.")
    token_payload = {"sub":str(existing.id)}
    access_token = create_access_token(token_payload)
    return {"access_token":access_token,"token_type":"bearer"}

async def get_me(db:AsyncSession,user_id:int):
    existing = await get_info(db,user_id)
    if not existing:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,detail="Kullancı bulunamadı")
    return existing