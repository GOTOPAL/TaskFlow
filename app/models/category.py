from sqlalchemy.orm import Mapped,mapped_column,relationship
from typing import List
from app.db.base import Base

class Category(Base):
    __tablename__ = "categories"
    id:Mapped[int] = mapped_column(primary_key=True)
    name:Mapped[str] = mapped_column(nullable=False,unique=True)
    
    tasks:Mapped[List["Task"]] = relationship("Task",back_populates="category")