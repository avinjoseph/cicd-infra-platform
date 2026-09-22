output "artifacts_bucket" {
  description = "S3 bucket used for build artifacts."
  value       = aws_s3_bucket.artifacts.bucket
}

output "ecr_repository_url" {
  description = "ECR repository URL for the application image."
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.app.name
}
