from datetime import datetime

from pydantic import BaseModel


class TaskBase(BaseModel):
    title: str
    done: bool = False


class TaskCreate(TaskBase):
    pass


class Task(TaskBase):
    id: int
    created_at: datetime
    updated_at: datetime
    user_id: int

    class Config:
        orm_mode = True
