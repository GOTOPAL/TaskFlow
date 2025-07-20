from fastapi import APIRouter,Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.category import Category
from sqlalchemy import select
from app.db.session import get_db
from app.schemas.categories import CategoryOut
from typing import List


router = APIRouter(prefix="/category",tags=["Category"])


@router.get("/",response_model=List[CategoryOut])
async def get_categories(db:AsyncSession=Depends(get_db)):
    result = await db.execute(select(Category))
    categories = result.scalars().all()
    return categories


@router.get("/{category_id}",response_model=CategoryOut)
async def get_category_id(category_id:int,db:AsyncSession=Depends(get_db)):
    result = await db.execute(select(Category).where(Category.id == category_id))
    category = result.scalar_one_or_none()
    return category