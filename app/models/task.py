from sqlalchemy.orm import mapped_column,Mapped,relationship
from sqlalchemy import ForeignKey,String,Integer,Text
from app.db.base import Base


class Task(Base):
    __tablename__ = "tasks"
    id:Mapped[int] = mapped_column(primary_key=True)
    context:Mapped[str] = mapped_column(String(100),nullable=False)
    description:Mapped[str] = mapped_column(Text,nullable=True)

    status: Mapped[str] = mapped_column(String(20), default="pending", nullable=False)
    priority: Mapped[int] = mapped_column(Integer, default=1, nullable=False)  # 1-low, 2-medium, 3-high gibi
    
    user_id:Mapped[int]=mapped_column(ForeignKey("users.id"))
    category_id:Mapped[int]=mapped_column(ForeignKey("categories.id"))
    user:Mapped["User"] = relationship("User",back_populates="tasks")
    category: Mapped["Category"] = relationship("Category", back_populates="tasks")
