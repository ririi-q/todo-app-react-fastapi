# Amplifyアプリケーションの作成
resource "aws_amplify_app" "frontend" {
  name         = "${var.project}-${var.env}-frontend"
  repository   = var.repository_url
  access_token = var.github_access_token

  # モノレポ設定
  build_spec = jsonencode({
    version = 1
    applications = [
      {
        appRoot = "frontend"
        frontend = {
          phases = {
            preBuild = {
              commands = [
                "npm ci"
              ]
            }
            build = {
              commands = [
                "npm run build"
              ]
            }
          }
          artifacts = {
            baseDirectory = "dist"
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
      }
    ]
  })

  # 環境変数
  environment_variables = {
    NODE_ENV     = var.env
    VITE_API_URL = "https://${var.api_domain}"
  }

  platform = "WEB"
  enable_branch_auto_build = true
  
}

# ブランチ設定
resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = "main"
  stage       = "PRODUCTION"
}

resource "aws_amplify_branch" "develop" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = "develop"
  stage       = "DEVELOPMENT"

  environment_variables = {
    NODE_ENV = "development"
  }
} 