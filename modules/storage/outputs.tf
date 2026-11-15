output "bucket_name" {
  description = "Nom du bucket S3"
  value       = local.bucket_id
}

output "bucket_arn" {
  description = "ARN du bucket S3"
  value       = local.bucket_arn
}
