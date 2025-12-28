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
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.example_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.example_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.example_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

############################################
# 6. Docker Host Configuration (SNA Task)
############################################

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "docker_sg" {
  name        = "docker-host-sg-${random_id.id.hex}"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Provision the EC2 Instance with Docker Pre-installed
resource "aws_instance" "docker_server" {
  ami = data.aws_ami.amazon_linux_2.id

  # UPDATED TO T3.MICRO FOR FREE TIER ELIGIBILITY
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.docker_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              systemctl enable docker
              usermod -a -G docker ec2-user
              
              # Pull and run a sample Nginx container to verify setup
              docker run -d -p 80:80 --name sna-web-container nginx
              EOF

  tags = {
    Name        = "SNA-Docker-Host"
    Environment = "Dev"
  }
}

############################################
# 7. Outputs
############################################
output "docker_host_public_ip" {
  value       = aws_instance.docker_server.public_ip
  description = "The public IP of the Docker host"
}