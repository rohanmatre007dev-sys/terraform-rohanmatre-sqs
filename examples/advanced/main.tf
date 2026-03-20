provider "aws" {
  region = "us-east-1"
}

################################################################################
# Advanced: Encrypted standard queue with SNS-sourced policy and DLQ
################################################################################

module "sqs_standard" {
  source = "../../"

  name = "advanced-queue"

  # Message behaviour
  visibility_timeout_seconds = 60
  message_retention_seconds  = 345600 # 4 days
  max_message_size           = 262144 # 256 KiB
  delay_seconds              = 0
  receive_wait_time_seconds  = 20 # long polling

  # Customer KMS encryption — sqs_managed_sse_enabled auto-disabled by locals.tf
  kms_master_key_id                 = "arn:aws:kms:us-east-1:012345678901:key/mrk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  kms_data_key_reuse_period_seconds = 3600

  # Queue policy — SNS publish + Lambda consume
  create_queue_policy = true
  queue_policy_statements = {
    sns_publish = {
      sid     = "SNSPublish"
      actions = ["sqs:SendMessage"]
      principals = [{
        type        = "Service"
        identifiers = ["sns.amazonaws.com"]
      }]
      condition = [{
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = ["arn:aws:sns:us-east-1:012345678901:my-topic"]
      }]
    }
    lambda_consume = {
      sid = "LambdaConsume"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility",
      ]
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::012345678901:role/my-lambda-role"]
      }]
    }
    cross_account_send = {
      sid     = "CrossAccountSend"
      actions = ["sqs:SendMessage"]
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::111122223333:role/sender-role"]
      }]
    }
  }

  # DLQ — auto-named "advanced-queue-dlq" via locals.tf
  create_dlq = true
  redrive_policy = {
    maxReceiveCount = 3
  }

  # DLQ retention set to max (14 days)
  dlq_message_retention_seconds = 1209600
  dlq_kms_master_key_id         = "arn:aws:kms:us-east-1:012345678901:key/mrk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # DLQ policy — allow ops team to inspect dead-lettered messages
  create_dlq_queue_policy = true
  dlq_queue_policy_statements = {
    ops_read = {
      sid = "OpsRead"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
      ]
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::012345678901:role/ops-role"]
      }]
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "prod"
    Example     = "advanced-standard"
  }

  dlq_tags = {
    Type        = "dead-letter"
    Environment = "prod"
  }
}

################################################################################
# Advanced: FIFO queue with content-based deduplication and FIFO DLQ
################################################################################

module "sqs_fifo" {
  source = "../../"

  name                        = "advanced-events.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  fifo_throughput_limit       = "perMessageGroupId"
  deduplication_scope         = "messageGroup"

  visibility_timeout_seconds = 30
  message_retention_seconds  = 259200 # 3 days
  receive_wait_time_seconds  = 20

  kms_master_key_id = "arn:aws:kms:us-east-1:012345678901:key/mrk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  create_queue_policy = true
  queue_policy_statements = {
    publisher = {
      sid     = "EventPublisher"
      actions = ["sqs:SendMessage"]
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::012345678901:role/event-publisher"]
      }]
    }
    consumer = {
      sid = "EventConsumer"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
      ]
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::012345678901:role/event-consumer"]
      }]
    }
  }

  # DLQ auto-named "advanced-events-dlq.fifo" via locals.tf
  create_dlq = true
  redrive_policy = {
    maxReceiveCount = 5
  }

  dlq_content_based_deduplication = true
  dlq_fifo_throughput_limit       = "perMessageGroupId"
  dlq_message_retention_seconds   = 1209600 # 14 days
  dlq_kms_master_key_id           = "arn:aws:kms:us-east-1:012345678901:key/mrk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  tags = {
    Terraform   = "true"
    Environment = "prod"
    Example     = "advanced-fifo"
  }
}
