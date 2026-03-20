provider "aws" {
  region = "us-east-1"
}

################################################################################
# Basic SQS Queue with Dead Letter Queue
################################################################################

module "sqs" {
  source = "../../"

  name = "basic-queue"

  # Message behaviour
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400 # 1 day
  delay_seconds              = 0
  receive_wait_time_seconds  = 20 # long polling

  # SQS-managed SSE (default)
  sqs_managed_sse_enabled = true

  # Dead Letter Queue — auto-named "basic-queue-dlq" via locals.tf
  create_dlq = true
  redrive_policy = {
    maxReceiveCount = 5
  }

  # Queue policy — allow Lambda to consume messages
  create_queue_policy = true
  queue_policy_statements = {
    lambda_consume = {
      sid     = "LambdaConsume"
      actions = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::012345678901:role/my-lambda-role"]
      }]
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Example     = "basic"
  }

  dlq_tags = {
    Type = "dead-letter"
  }
}
