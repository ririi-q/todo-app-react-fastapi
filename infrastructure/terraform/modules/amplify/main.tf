# Amplifyアプリケーションの作成
resource "aws_amplify_app" "frontend" {
  name         = "${var.project}-${var.env}-frontend"
  repository   = var.repository_url
  access_token = var.github_access_token

  # Vite + React用の設定
  platform = "WEB"

  # ビルド設定
  build_spec = jsonencode({
    version = 1
    frontend = {
      phases = {
        preBuild = {
          commands = [
            "npm ci"  # または "yarn install" / "pnpm install"
          ]
        }
        build = {
          commands = [
            "npm install && npm run build"  # Viteのビルドコマンド
          ]
        }
      }
      artifacts = {
        baseDirectory = "dist"  # Viteのデフォルトビルド出力ディレクトリ
        files = [
          "**/*"
        ]
      }
      cache = {
        paths = [
          "node_modules/**/*"
        ]
      }
    }
  })

  # 環境変数
  environment_variables = {
    NODE_ENV        = var.env
    VITE_API_URL    = "https://${var.api_domain}"  # Viteの環境変数はVITE_プレフィックスが必要
  }

  # 自動ビルドの有効化
  enable_branch_auto_build = true
}

# メインブランチの設定
resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = "main"
  stage       = "PRODUCTION"

  environment_variables = {
    ENVIRONMENT = "prod"
  }
}

# 開発ブランチの設定
resource "aws_amplify_branch" "develop" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = "develop"
  stage       = "DEVELOPMENT"

  environment_variables = {
    ENVIRONMENT = "dev"
  }
} 