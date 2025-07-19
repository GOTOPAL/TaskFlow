from fastapi import Depends,HTTPException,status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.auth.jwt import decode_access_token
from app.crud.user import get_user_by_user_id


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/login")

async def get_current_user(token:str=Depends(oauth2_scheme),db:AsyncSession=Depends(get_db)):
    id = decode_access_token(token)
    if not id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,detail="Geçersiz token.")
    user = await get_user_by_user_id(db,id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail="Kullanıcı bulunamadı.")
    return user
