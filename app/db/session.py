from sqlalchemy.ext.asyncio import AsyncSession,create_async_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

engine = create_async_engine(settings.database_url)

AsyncSessionLocal = sessionmaker(bind=engine,class_= AsyncSession,expire_on_commit=False,autoflush=False)

async def get_db():
    async with AsyncSessionLocal() as session:
        yield session