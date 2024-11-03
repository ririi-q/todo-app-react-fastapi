import pytest
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Task, User
from app.schemas.task import TaskCreate, TaskUpdate


@pytest.fixture
async def test_user(session: AsyncSession):
    user = User(name="testuser")
    session.add(user)
    await session.commit()
    await session.refresh(user)
    return user


@pytest.fixture
async def test_task(session: AsyncSession, test_user: User):
    task = Task(title="テストタスク", done=False, user_id=test_user.id)
    session.add(task)
    await session.commit()
    await session.refresh(task)
    return task


@pytest.mark.asyncio
async def test_create_task(session: AsyncSession, test_user: User):
    task_data = TaskCreate(title="新しいタスク", done=False)
    new_task = Task(**task_data.model_dump(), user_id=test_user.id)
    session.add(new_task)
    await session.commit()
    await session.refresh(new_task)

    assert new_task.title == task_data.title
    assert new_task.done == task_data.done
    assert new_task.user_id == test_user.id


@pytest.mark.asyncio
async def test_get_tasks(session: AsyncSession, test_user: User, test_task: Task):
    async with session:
        result = await session.execute(
            select(Task).filter(Task.user_id == test_user.id)
        )
        tasks = result.scalars().all()
        assert len(tasks) == 1
        assert tasks[0].title == test_task.title
        assert tasks[0].done == test_task.done


@pytest.mark.asyncio
async def test_update_task(session: AsyncSession, test_user: User, test_task: Task):
    async with session:
        update_data = TaskUpdate(title="更新されたタスク", done=True)
        stmt = select(Task).where(Task.id == test_task.id, Task.user_id == test_user.id)
        result = await session.execute(stmt)
        task = result.scalar_one()

        for key, value in update_data.model_dump().items():
            setattr(task, key, value)

        await session.commit()
        await session.refresh(task)

        result = await session.execute(select(Task).filter_by(id=test_task.id))
        updated_task = result.scalar_one()
        assert updated_task.title == update_data.title
        assert updated_task.done == update_data.done


@pytest.mark.asyncio
async def test_delete_task(session: AsyncSession, test_user: User, test_task: Task):
    async with session:
        stmt = select(Task).where(Task.id == test_task.id, Task.user_id == test_user.id)
        result = await session.execute(stmt)
        task = result.scalar_one()
        await session.delete(task)
        await session.commit()

        result = await session.execute(select(Task).filter_by(user_id=test_user.id))
        remaining_tasks = result.scalars().all()
        assert len(remaining_tasks) == 0


@pytest.mark.asyncio
async def test_task_done_flag(session: AsyncSession, test_user: User):
    async with session:
        task_data = TaskCreate(title="完了フラグのテスト")
        new_task = Task(**task_data.model_dump(), user_id=test_user.id)
        session.add(new_task)
        await session.commit()
        await session.refresh(new_task)

        assert new_task.done is False

        new_task.done = True
        await session.commit()
        await session.refresh(new_task)

        assert new_task.done is True
