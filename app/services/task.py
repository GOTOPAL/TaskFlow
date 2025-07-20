from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.task import AddTask, UpdateTask
from app.models.category import Category
from app.crud.task import add_task, delete_task, get_task_by_id_and_user, update_task_in_db


async def get_task_id_service(db:AsyncSession,user_id:int,task_id:int):
    result = await get_task_by_id_and_user(db,task_id,user_id)
    if not result:
        raise HTTPException(status_code=404, detail="Görev bulunamadı veya yetkiniz yok!")
    return  result

async def add_task_service(db: AsyncSession, task_data: AddTask, user_id: int):
    # 1. Kategori kontrolü (kategori var mı?)
    category = await db.get(Category, task_data.category_id)
    if not category:
        raise HTTPException(status_code=400, detail="Kategori bulunamadı!")
    
    return await add_task(db,task_data,user_id)

async def update_task_service(db:AsyncSession,task_id:int,user_id:int,update_data:UpdateTask):
    task = await get_task_by_id_and_user(db,task_id,user_id)
    if not task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı veya yetkiniz yok!")
    # 2. Kategori kontrolü (değişiyorsa)
    if update_data.category_id is not None:
        category = await db.get(Category, update_data.category_id)
        if not category:
            raise HTTPException(status_code=400, detail="Kategori bulunamadı!")
        
    # update_data model_dump(exclude_unset=True) ile dict'e çevrilir:
    update_fields = update_data.model_dump(exclude_unset=True)
    for key, value in update_fields.items():
        setattr(task, key, value)

    # 4. DB'de güncelle (CRUD fonksiyonu)
    return await update_task_in_db(db, task)

async def delete_task_service(db:AsyncSession,task_id:int,user_id:int):
    task = await get_task_by_id_and_user(db,task_id,user_id)
    if not task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı veya yetkiniz yok!")
    return await delete_task(db,task)