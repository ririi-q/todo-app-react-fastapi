# ToDo Manager

## プロジェクト概要

タスク管理のためのモダンなウェブアプリケーションです。フロントエンドからインフラストラクチャまで、最新のベストプラクティスを実践しています。

## 主な機能

- タスクの作成・編集・削除
- タスクのステータス管理（完了・未完了）
- タスクの検索とフィルタリング
- ページネーション機能
- レスポンシブデザイン

## 技術スタック

### フロントエンド

- React + TypeScript
- Vite
- TailwindCSS + shadcn/ui
- TanStack Table（高度なテーブル管理）

### バックエンド

- FastAPI（非同期処理対応）
- SQLAlchemy（ORM マッピング）
- Alembic（マイグレーション管理）
- PostgreSQL
- uvicorn（ASGI サーバー）

### インフラストラクチャ

- AWS
  - ECS Fargate（コンテナオーケストレーション）
  - ECR（コンテナレジストリ）
  - RDS PostgreSQL（データベース）
  - Application Load Balancer
  - AWS Amplify（フロントエンドホスティング）
  - Route53 + ACM（DNS 管理と SSL/TLS 証明書）
- Terraform（IaC）
- Docker（コンテナ化）

## アーキテクチャの特徴

### マイクロサービスアーキテクチャ

フロントエンドとバックエンドを分離し、それぞれを独立したサービスとして運用しています。

### セキュアな設計

```59:71:infrastructure/terraform/modules/database/main.tf
  # バックアップ設定
  backup_retention_period = var.env == "prod" ? 7 : 1
  backup_window          = "17:00-18:00"
  maintenance_window     = "Mon:18:00-Mon:19:00"

  # 暗号化設定
  storage_encrypted = true

  # パフォーマンスインサイト
  performance_insights_enabled = var.env == "prod"

  # 削除保護（本番環境のみ）
  deletion_protection = var.env == "prod"
```

### スケーラブルなインフラストラクチャ

```159:185:infrastructure/terraform/modules/container/main.tf
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project}-${var.env}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = "${aws_ecr_repository.backend.repository_url}:latest"

      systemControls = [
        {
          namespace = "net.core.somaxconn"
          value     = "1024"
        }
      ]

      ulimits = [
        {
          name      = "nofile"
          softLimit = 65536
          hardLimit = 65536
        }
      ]
```

### 効率的な開発環境

```1:49:infrastructure/docker/compose.yml
name: todo-app-local

services:
  frontend:
    build:
      context: ../../frontend
      dockerfile: Dockerfile.local
    container_name: todo-app-frontend
    ports:
      - "5173:5173"
    volumes:
      - ../../frontend:/app
      - /app/node_modules
      - ../../frontend/.env.${ENVIRONMENT:-localhost}:/app/.env.${ENVIRONMENT:-localhost}
    environment:
      - ENVIRONMENT=${ENVIRONMENT:-localhost}

  backend:
    build:
      context: ../../backend
      dockerfile: Dockerfile.local
    container_name: todo-app-backend
    ports:
      - "8000:8000"
    volumes:
      - ../../backend:/app
      - ../../backend/db/init:/docker-entrypoint-initdb.d
      - ../../backend/.env.${ENVIRONMENT:-local}:/app/.env.${ENVIRONMENT:-local}
    environment:
      - ENVIRONMENT=${ENVIRONMENT:-local}
    depends_on:
      - db

  db:
    image: postgres:17-alpine
    container_name: todo-app-db
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ../../backend/db/init:/docker-entrypoint-initdb.d

volumes:
  postgres_data:

```

## ローカル開発環境のセットアップ

### バックエンド

```bash
cd backend
uv venv
source .venv/bin/activate
uv pip install --requirement pyproject.toml
```

### フロントエンド

```bash
cd frontend
npm install
npm run dev
```

### Docker 環境

```bash
cd infrastructure/docker
docker compose up -d
```

## デプロイメントフロー

### CI/CD

GitHub Actions を使用して、以下のワークフローを自動化しています：

```59:84:.github/workflows/deploy-backend.yml
  deploy:
    needs: test
    if: |
      github.event_name == 'push' &&
      (github.ref == 'refs/heads/main' ||
       github.ref == 'refs/heads/develop')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set environment variables
        run: |
          if [[ $GITHUB_REF == 'refs/heads/main' ]]; then
            echo "ENVIRONMENT=prod" >> $GITHUB_ENV
          else
            echo "ENVIRONMENT=dev" >> $GITHUB_ENV
          fi

          echo "PROJECT_NAME=todo-app-1" >> $GITHUB_ENV

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-northeast-1
```

## テスト

### バックエンドテスト

```1:49:backend/tests/test_tasks.py
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
```

## インフラストラクチャ管理

### Terraform の使用

`````38:56:infrastructure/README.md
## Usage

1. Initialize Terraform:
```bash
cd terraform/envs/dev
terraform init
````

2. Plan the changes:

```bash
terraform plan
```

3. Apply the changes:

```bash
terraform apply
```
`````

## セキュリティ対策

### バックエンド

- 非 root ユーザーでのコンテナ実行
- セキュリティアップデートの自動適用
- 環境変数による機密情報管理

### データベース

- プライベートサブネットでの運用
- バックアップの自動取得
- 暗号化ストレージの使用

### ネットワーク

- VPC による分離
- セキュリティグループによるアクセス制御
- HTTPS の強制

## 今後の展望

- ユーザー認証の実装
- テストカバレッジの向上
- パフォーマンスモニタリングの強化
- 多言語対応

## ライセンス

MIT

## 作者

Ririi
