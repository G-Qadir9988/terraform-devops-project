# --- main.tf ---

############################################
# 1. Terraform & Provider Configuration
############################################
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  ##########################################
  # 7. Remote Backend (S3 + DynamoDB Lock)
  ##########################################
  backend "s3" {
    # CHANGE THESE TO MATCH THE RESOURCES
    # YOU CREATED MANUALLY IN AWS
    bucket         = "gqadir-tf-state-lock-2025"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-table"
    encrypt        = true
  }
}

############################################
# 2. AWS Provider
############################################
# Credentials are automatically picked up from:
# - AWS CLI (local)
# - GitHub Actions via OIDC (CI/CD)
provider "aws" {
  region = "us-east-1"
}

############################################
# 3. Helper Resource (Unique ID)
############################################
resource "random_id" "id" {
  byte_length = 4
}

############################################
# 4. Sample Resource (S3 Bucket)
############################################
resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-devops-project-bucket-abc-${random_id.id.hex}"

  tags = {
    Name        = "DevOps Project Bucket"
    Environment = "Dev"
  }
}

############################################
# 5. Recommended Security Settings
############################################
# Block all public access
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.example_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.example_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.example_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
