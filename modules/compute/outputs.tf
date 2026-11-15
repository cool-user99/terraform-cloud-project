output "asg_name" {
  description = "Nom de l'Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "Identifiant du Launch Template"
  value       = aws_launch_template.app.id
}
