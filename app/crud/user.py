from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from sqlalchemy import select
from app.models.user import User
from app.schemas.user import UserCreate,UserLogin
from app.auth.security import get_password_hash

async def get_user_by_user_id(db:AsyncSession ,  user_id:str)->User:
    stmt = select(User).where(User.id == user_id)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()

async def existing_user(db:AsyncSession,email:str):
    stmt = select(User).where(User.email == email)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()

async def create_user(db:AsyncSession,user_data:UserCreate):
    data = user_data.model_dump(exclude={"password"})
    password = user_data.password
    hashed_pw = get_password_hash(password)
    user = User(**data,hashed_password = hashed_pw)
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user

# #existing_user() da kullanılabilirdi ama öğrenmek için yaptım
async def get_me(db:AsyncSession,user_id:int):
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()