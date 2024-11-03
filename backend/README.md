```bash
cd backend
uv init .
uv python pin 3.12
uv sync
uv venv
source .venv/bin/activate
uv pip install --requirement pyproject.toml

uv add fastapi uvicorn sqlalchemy alembic psycopg2-binary python-dotenv
uv add --dev ruff pytest httpx

# コードのフォーマット
uv run ruff format .

# リンターの実行と自動修正
uv run ruff check . --fix

# テストの実行
uv run pytest tests/ -v
```
