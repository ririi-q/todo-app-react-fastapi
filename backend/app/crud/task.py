from sqlalchemy.orm import Session

from app.models import task as models
from app.schemas import task as schemas


def get_tasks(db: Session, user_id: int, skip: int = 0, limit: int = 100):
    return (
        db.query(models.Task)
        .filter(models.Task.user_id == user_id)
        .offset(skip)
        .limit(limit)
        .all()
    )

def create_user_task(db: Session, task: schemas.TaskCreate, user_id: int):
    new_task = models.Task(**task.dict(), user_id=user_id)
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    return new_task

def update_user_task(db: Session, task: schemas.TaskUpdate, user_id: int, task_id: int):
    db.query(models.Task).filter(models.Task.id == task_id, models.Task.user_id == user_id).update(task.dict())
    db.commit()
    return db.query(models.Task).filter(models.Task.id == task_id, models.Task.user_id == user_id).first()

def delete_user_task(db: Session, user_id: int, task_id: int):
    db.query(models.Task).filter(models.Task.id == task_id, models.Task.user_id == user_id).delete()
    db.commit()
