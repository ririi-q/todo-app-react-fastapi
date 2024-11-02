

``` bash
cd backend
uv init .
uv sync
uv venv
uv python pin 3.12

uv add fastapi uvicorn sqlalchemy alembic psycopg2-binary python-dotenv    
uv add --dev ruff pytest httpx

# コードのフォーマット
uv run ruff format .

# リンターの実行と自動修正
uv run ruff check . --fix
```