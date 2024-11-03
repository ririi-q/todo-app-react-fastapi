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


@router.put("/users/{user_id}/tasks/{task_id}", response_model=schemas.Task)
def update_task_for_user(
    user_id: int, task_id: int, task: schemas.TaskUpdate, db: Session = Depends(get_db)
):
    return crud.update_user_task(db=db, task=task, user_id=user_id, task_id=task_id)


@router.delete("/users/{user_id}/tasks/{task_id}")
def delete_task_for_user(user_id: int, task_id: int, db: Session = Depends(get_db)):
    return crud.delete_user_task(db=db, user_id=user_id, task_id=task_id)
