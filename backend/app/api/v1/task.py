from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import SessionLocal
from app.crud import task as crud
from app.schemas import task as schemas

router = APIRouter()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.get("/users/{user_id}/tasks", response_model=list[schemas.Task])
def read_tasks(
    user_id: int, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
):
    tasks = crud.get_tasks(db, user_id=user_id, skip=skip, limit=limit)
    return tasks


@router.post("/users/{user_id}/tasks", response_model=schemas.Task)
def create_task_for_user(
    user_id: int, task: schemas.TaskCreate, db: Session = Depends(get_db)
):
    return crud.create_user_task(db=db, task=task, user_id=user_id)
