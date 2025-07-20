from fastapi import APIRouter,Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.auth.dependencies import get_current_user
from app.crud.task import get_tasks
from app.models.user import User
from app.schemas.task import TaskOut,AddTask,UpdateTask
from typing import List
from app.services.task import add_task_service, delete_task_service, get_task_id_service, update_task_service

router = APIRouter(prefix="/tasks",tags=["Task"])

@router.get("/",response_model = List[TaskOut])
async def get_all_task(db:AsyncSession=Depends(get_db) ,current_user : User = Depends(get_current_user)):
    return await get_tasks(db,current_user.id)

@router.get("/{task_id}",response_model=TaskOut)
async def get_task(task_id:int,db:AsyncSession=Depends(get_db),current_user:User=Depends(get_current_user)):
    return await get_task_id_service(db,current_user.id,task_id)
    
@router.post("/", response_model=TaskOut)
async def create_task(task: AddTask,db: AsyncSession = Depends(get_db),current_user: User = Depends(get_current_user)):
    return await add_task_service(db, task, current_user.id)

@router.patch("/{task_id}",response_model=TaskOut)
async def update_task(task_id : int,update_data : UpdateTask,db:AsyncSession = Depends(get_db),current_user:User=Depends(get_current_user)):
    return await update_task_service(db,task_id,current_user.id,update_data)

@router.delete("/{task_id}")
async def delete_task(task_id:int,db:AsyncSession=Depends(get_db),current_user:User=Depends(get_current_user)):
    return await delete_task_service(db,task_id,current_user.id)