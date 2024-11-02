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
