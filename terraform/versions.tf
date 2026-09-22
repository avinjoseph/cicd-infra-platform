terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

# By default this points at LocalStack (a free, local AWS emulator) so the
# whole stack can be provisioned and destroyed with zero cloud spend.
# To target a real AWS account instead, set use_localstack = false and
# configure real credentials via environment variables / AWS SSO.
provider "aws" {
  region                      = var.aws_region
  access_key                  = var.use_localstack ? "test" : null
  secret_key                  = var.use_localstack ? "test" : null
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
          s3     = "http://127.0.0.1:4566"
          ecr    = "http://127.0.0.1:4566"
          ecs    = "http://127.0.0.1:4566"
          iam    = "http://127.0.0.1:4566"
          logs   = "http://127.0.0.1:4566"
          ec2    = "http://127.0.0.1:4566"
          sts    = "http://127.0.0.1:4566"
    }
  }
}
