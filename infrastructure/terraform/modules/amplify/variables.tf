variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "repository_url" {
  type = string
}

variable "github_access_token" {
  type      = string
  sensitive = true
}

variable "api_domain" {
  type = string
} 