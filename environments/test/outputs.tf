output "vpc_id" {
  description = "Identifiant du VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Sous-reseaux publics"
  value       = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Sous-reseaux prives applicatifs"
  value       = module.network.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Sous-reseaux prives de base de donnees"
  value       = module.network.private_db_subnet_ids
}
