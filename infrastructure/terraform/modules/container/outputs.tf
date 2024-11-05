output "api_domain" {
  description = "Domain name of the API"
  value       = aws_lb.main.dns_name
} 

# アウトプットの修正
output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "alb_zone_id" {
  value = aws_lb.main.zone_id
}