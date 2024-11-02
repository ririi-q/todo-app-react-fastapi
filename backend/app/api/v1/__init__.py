from fastapi import APIRouter

from app.api.v1 import task, user

router = APIRouter()

router.include_router(user.router, prefix="/users", tags=["users"])

router.include_router(task.router, tags=["tasks"])
