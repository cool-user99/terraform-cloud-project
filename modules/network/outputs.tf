output "vpc_id" {
  description = "Identifiant du VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "Bloc CIDR du VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Identifiants des sous-reseaux publics"
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "Identifiants des sous-reseaux prives applicatifs"
  value       = aws_subnet.private_app[*].id
}

output "private_db_subnet_ids" {
  description = "Identifiants des sous-reseaux prives de base de donnees"
  value       = aws_subnet.private_db[*].id
}

output "nat_public_ips" {
  description = "Adresses IP publiques des NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}
