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
                "npm install && npm run build"
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



  platform = "WEB"
  enable_branch_auto_build = true
  
}

# ブランチ設定
resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = "main"
  stage       = "PRODUCTION"

  # 環境変数
  environment_variables = {
    NODE_ENV     = "prod"
    ENVIRONMENT  = "prod"
    VITE_API_URL = "https://${var.api_domain}"
  }
}

resource "aws_amplify_branch" "develop" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = "develop"
  stage       = "DEVELOPMENT"

  # 環境変数
  environment_variables = {
    NODE_ENV     = "dev"
    ENVIRONMENT  = "dev"
    VITE_API_URL = "http://${var.api_domain}"
  }
} 