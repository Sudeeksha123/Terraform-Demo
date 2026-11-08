
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

# Find Amazon Linux 2023 AMI
data "aws_ami" "acme_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Provision Acme development server
resource "aws_instance" "acme_dev" {
  ami           = data.aws_ami.acme_linux.id
  instance_type = "t3.micro"

  # Reuse existing AWS networking
  subnet_id = "subnet-00d25d7f3eef41262"

  # No public IP or inbound access needed for demo
  associate_public_ip_address = false

  tags = {
    Name        = "acme-dev-server"
    Environment = "dev"
    Project     = "acme-self-service"
    ManagedBy   = "terraform"
  }
}

# Output EC2 instance details
output "ec2_instance_id" {
  value = aws_instance.acme_dev.id
}

output "ec2_private_ip" {
  value = aws_instance.acme_dev.private_ip
}
