from sqlalchemy.ext.asyncio import AsyncSession
from app.models.task import Task
from sqlalchemy import select



async def get_tasks(db:AsyncSession,user_id:int):
    stmt = select(Task).where(Task.user_id==user_id)
    result = await db.execute(stmt)
    tasks = result.scalars().all()
    return tasks