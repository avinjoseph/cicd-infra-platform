variable "use_localstack" {
  description = "Route all AWS API calls to a local LocalStack instance instead of real AWS. Keeps the whole project free to run."
  type        = bool
  default     = true
}

variable "aws_region" {
  description = "AWS region to provision resources in."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short name used to prefix/tag all resources."
  type        = string
  default     = "cicd-infra-demo"
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "container_image" {
  description = "Full image reference (repo:tag) to deploy, e.g. ghcr.io/you/cicd-infra-demo:sha-abc123."
  type        = string
  default     = "cicd-infra-demo:local"
}

variable "container_port" {
  description = "Port the application listens on inside the container."
  type        = number
  default     = 8000
}

variable "desired_count" {
  description = "Number of ECS tasks to run."
  type        = number
  default     = 1
}
