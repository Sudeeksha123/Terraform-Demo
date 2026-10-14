
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Connect to AWS in Ohio
provider "aws" {
  region = "us-east-2"
}

# Verify AWS connection
data "aws_caller_identity" "current" {}

# Create an S3 bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket_prefix = "spasula-terraform-demo-"

  tags = {
    Name        = "Terraform-Demo"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "demo_security" {
  bucket = aws_s3_bucket.demo_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Display AWS account ID
output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

# Display S3 bucket name
output "s3_bucket_name" {
  value = aws_s3_bucket.demo_bucket.bucket
}

# Display AWS region
output "aws_region" {
  value = "us-east-2"
}
