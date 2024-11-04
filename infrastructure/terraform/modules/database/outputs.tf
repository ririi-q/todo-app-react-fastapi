output "db_instance_endpoint" {
  description = "The endpoint of the database"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.main.db_name
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.main.port
}

output "db_security_group_id" {
  description = "The security group ID of the database"
  value       = aws_security_group.rds.id
}

output "db_endpoint" {
  description = "The endpoint of the database"
  value       = aws_db_instance.main.endpoint
}