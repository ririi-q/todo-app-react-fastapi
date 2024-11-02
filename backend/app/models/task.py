from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from ..core.database import Base


class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    done = Column(Boolean, default=False, index=True)
    created_at = Column(DateTime, default=datetime.now(), nullable=False)
    updated_at = Column(
        DateTime, default=datetime.now(), onupdate=datetime.now(), nullable=False
    )
    user_id = Column(Integer, ForeignKey("users.id"))

    user = relationship("User", back_populates="tasks")
