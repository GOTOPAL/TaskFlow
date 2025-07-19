from fastapi import APIRouter,Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.auth.dependencies import get_current_user
from app.crud.task import get_tasks
from app.models.user import User
from app.schemas.task import TaskOut
from typing import List

router = APIRouter()

@router.get("/",response_model = List[TaskOut])
async def get_all_task(db:AsyncSession=Depends(get_db) ,current_user : User = Depends(get_current_user)):
    return await get_tasks(db,current_user.id)
    