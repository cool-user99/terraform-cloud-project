output "db_endpoint" {
  description = "Point d'acces de la base (hote:port)"
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "Nom d'hote de la base"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Port de la base"
  value       = aws_db_instance.this.port
}

output "db_secret_arn" {
  description = "ARN du secret Secrets Manager contenant le mot de passe (null si use_secrets_manager = false)"
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
}
