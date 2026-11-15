output "alb_dns_name" {
  description = "Nom DNS du Load Balancer"
  value       = aws_lb.this.dns_name
}

output "alb_arn" {
  description = "ARN du Load Balancer"
  value       = aws_lb.this.arn
}

output "alb_arn_suffix" {
  description = "Suffixe ARN du Load Balancer (metriques CloudWatch, politique de scaling)"
  value       = aws_lb.this.arn_suffix
}

output "target_group_arn" {
  description = "ARN du Target Group a associer a l'Auto Scaling Group"
  value       = aws_lb_target_group.app.arn
}

output "target_group_arn_suffix" {
  description = "Suffixe ARN du Target Group (metriques CloudWatch, politique de scaling)"
  value       = aws_lb_target_group.app.arn_suffix
}
