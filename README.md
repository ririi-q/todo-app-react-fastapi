# バックエンドのディレクトリ構造を表示（キャッシュファイルなどを除外）

tree -I "**pycache**|_.pyc|.venv|.pytest_cache|.ruff_cache|db/development/versions/_" ./backend

# フルパスで表示する場合は -f オプションを追加

tree -f -I "**pycache**|_.pyc|.venv|.pytest_cache|.ruff_cache|db/development/versions/_" ./backend

# ディレクトリのみ表示する場合は -d オプションを追加

tree -d -I "**pycache**|.venv|.pytest_cache|.ruff_cache" ./backend
