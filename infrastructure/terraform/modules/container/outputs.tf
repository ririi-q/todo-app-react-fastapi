output "api_domain" {
  description = "Domain name of the API"
  value       = aws_lb.main.dns_name
} 