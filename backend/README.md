```bash
cd backend
uv init .
uv python pin 3.12
uv sync
uv venv
source .venv/bin/activate
uv pip install --requirement pyproject.toml

## Docker環境に入ってから行ってください
uv add fastapi uvicorn sqlalchemy alembic psycopg2-binary python-dotenv
uv add --dev ruff pytest httpx

uv run alembic init local
uv run alembic init development
uv run alembic init staging
uv run alembic init production

uv run alembic revision --autogenerate -m "init"
uv run alembic upgrade head

uv run uvicorn app.main:app --reload --env-file .env.local --host 0.0.0.0 --port 8000

# コードのフォーマット
uv run ruff format .

# リンターの実行と自動修正
uv run ruff check . --fix

# テストの実行
uv run pytest tests/ -v
```
