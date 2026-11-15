output "alb_sg_id" {
  description = "Security Group du Load Balancer"
  value       = aws_security_group.alb.id
}

output "app_sg_id" {
  description = "Security Group des instances applicatives"
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "Security Group de la base de donnees"
  value       = aws_security_group.db.id
}

output "instance_profile_name" {
  description = "Nom du profil d'instance a associer au Launch Template"
  value       = var.create_iam_role ? aws_iam_instance_profile.app[0].name : var.instance_profile_name
}
