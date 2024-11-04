# backend/Dockerfile
FROM python:3.12-slim as builder

WORKDIR /app

# セキュリティアップデートとビルド依存関係のインストール
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 依存関係のインストール
RUN pip install --no-cache-dir uv
RUN uv venv
COPY pyproject.toml .
RUN uv sync
RUN uv pip install --requirement pyproject.toml

# 実行ステージ
FROM python:3.12-slim

WORKDIR /app

# セキュリティアップデート
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    curl \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

# 仮想環境のコピー
COPY --from=builder /app/.venv /app/.venv
ENV PATH="/app/.venv/bin:$PATH"

# アプリケーションコードのコピー
COPY ./app ./app
COPY ./db ./db
COPY ./docker-entrypoint.sh ./

# エントリーポイントの改行コード修正と実行権限付与
RUN dos2unix /app/docker-entrypoint.sh && \
    chmod +x /app/docker-entrypoint.sh

# 非rootユーザーの作成
RUN useradd -r -s /bin/false appuser && \
    chown -R appuser:appuser /app

USER appuser

# ヘルスチェックの追加
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000

ENTRYPOINT ["/bin/sh", "/app/docker-entrypoint.sh"]
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]