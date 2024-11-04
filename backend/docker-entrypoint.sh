#!/bin/sh
set -e

# 環境変数のデフォルト値設定
ENVIRONMENT=${ENVIRONMENT:-local}
MIGRATE=${MIGRATE:-true}
SEED=${SEED:-false}

# データベースのマイグレーション
if [ "$MIGRATE" = "true" ]; then
    echo "Running database migrations..."
    alembic upgrade head
fi

# 開発環境、ローカル環境の場合のみシードデータを投入
if [ "$SEED" = "true" ] && ([ "$ENVIRONMENT" = "development" ] || [ "$ENVIRONMENT" = "local" ]); then
    echo "Running database seeds... now no seed"
fi

# 渡されたコマンドを実行
exec "$@"