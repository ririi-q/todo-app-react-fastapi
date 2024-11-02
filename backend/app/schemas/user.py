from datetime import datetime

from pydantic import BaseModel

from .task import Task


class UserBase(BaseModel):
    name: str


class UserCreate(UserBase):
    pass


class User(UserBase):
    id: int
    created_at: datetime
    tasks: list[Task] = []

    class Config:
        orm_mode = True
