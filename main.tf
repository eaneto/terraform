terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  access_key                  = "mock_access_key"
  region                      = "us-east-1"
  s3_force_path_style         = true
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    dynamodb = "http://localhost:4566"
    sqs      = "http://localhost:4566"
    s3       = "http://localhost:4566"
  }
}

# Create S3 bucket
resource "aws_s3_bucket" "examplebucket" {
  bucket = "eanetos-test-bucket"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# Create DynamoDB Table
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "my-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "some-id"

  attribute {
    name = "some-id"
    type = "S"
  }

  tags = {
    Environment = "dev"
  }
}

# Create SQS Queue
resource "aws_sqs_queue" "example_queue" {
  name                      = "terraform-example-queue"
  delay_seconds             = 90 # 3 seconds
  max_message_size          = 2048 # 2K
  message_retention_seconds = 86400 # 1 day
  receive_wait_time_seconds = 10
  # Retryfour times
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.example_queue_dlq.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "dev"
  }
}

# Create SQS DLQ
resource "aws_sqs_queue" "example_queue_dlq" {
  name                      = "terraform-example-queue-dlq"
  max_message_size          = 2048 # 2K
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Environment = "dev"
  }
}
