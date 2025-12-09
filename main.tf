# --- main.tf ---

# 1. Define the required AWS provider and minimum Terraform version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 2. Configure the AWS Provider
# The credentials will be picked up from the AWS CLI config locally,
# or from GitHub Secrets/OIDC in the CI/CD pipeline.
provider "aws" {
  region = "us-east-1" # Must match the region used in GitHub Actions workflow (terraform.yml)
}

# 3. Define a sample resource (an S3 bucket)
resource "aws_s3_bucket" "example_bucket" {
  # FIX: Changed from $(...) to ${...} for correct Terraform interpolation.
  # Also slightly simplified the name to ensure compliance.
  bucket = "my-devops-project-bucket-abc-${random_id.id.hex}"

  tags = {
    Name        = "DevOps Project Bucket"
    Environment = "Dev"
  }
}

# Helper resource to generate a unique suffix for the bucket name
resource "random_id" "id" {
  byte_length = 4
}