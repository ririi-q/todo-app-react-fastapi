terraform {
  backend "s3" {
    bucket         = "584335737723-terraform-state"
    key            = "projects/todo-app-1/dev/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "584335737723-terraform-state-lock"
  }
} 