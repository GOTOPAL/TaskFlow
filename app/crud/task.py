from sqlalchemy.ext.asyncio import AsyncSession
from app.models.task import Task
from sqlalchemy import select
from app.schemas.task import AddTask
from app.services.notification import send_notification_to_user


async def get_tasks(db:AsyncSession,user_id:int):
    stmt = select(Task).where(Task.user_id==user_id)
    result = await db.execute(stmt)
    tasks = result.scalars().all()
    return tasks


async def get_task(db:AsyncSession,user_id:int):
    pass

async def add_task(db: AsyncSession, task_data: AddTask, user_id: int):
    task = Task(**task_data.model_dump(), user_id=user_id)
    db.add(task)
    await db.commit()
    await db.refresh(task)


     # 2️⃣ Oluşturan kullanıcıya bildirim gönder
    await send_notification_to_user(
        user_id=user_id,
        db=db,
        title="✅ Görev Oluşturuldu",
        body=f"'{task.title}' adlı görev başarıyla oluşturuldu."
    )
    return task

# Görev bul (id ve user_id ile)

async def get_task_by_id_and_user(db:AsyncSession,task_id:int,user_id:int):
    result = await db.execute(select(Task).where(Task.id == task_id,Task.user_id==user_id))
    return result.scalar_one_or_none()

# Güncelle ve kaydet
async def update_task_in_db(db: AsyncSession, task: Task):
    db.add(task)
    await db.commit()
    await db.refresh(task)
    return task


async def delete_task(db:AsyncSession,task:Task):
    await db.delete(task)
    await db.commit()
    return {"success": True, "message": "İşlem başarılı"}