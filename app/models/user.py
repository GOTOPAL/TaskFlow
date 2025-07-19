from sqlalchemy.orm import Mapped,mapped_column,relationship
from sqlalchemy import String
from app.db.base import Base
from typing import List

class User(Base):
    __tablename__ = "users"
    id : Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(30),nullable=False)
    surname: Mapped[str] = mapped_column(String(30),nullable=False)
    hashed_password:Mapped[str] = mapped_column(nullable=False)
    email:Mapped[str] = mapped_column(nullable=False,unique=True)
    email_verified:Mapped[bool] = mapped_column(nullable=False,default=False)
    is_active:Mapped[bool] = mapped_column(nullable=False,default=True)

    tasks:Mapped[List["Task"]] = relationship("Task",back_populates="user",cascade="all,delete-orphan")

    