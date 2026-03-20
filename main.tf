################################################################################
# SQS Module Wrapper
# Wraps terraform-aws-modules/sqs/aws
################################################################################

module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = ">= 4.2"

  ################################################################################
  # Queue
  ################################################################################

  create          = var.create
  name            = var.name
  use_name_prefix = var.use_name_prefix
  region          = var.region

  # Message behaviour
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  max_message_size           = var.max_message_size
  delay_seconds              = var.delay_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  # FIFO
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.content_based_deduplication
  deduplication_scope         = var.deduplication_scope
  fifo_throughput_limit       = var.fifo_throughput_limit

  # Encryption
  sqs_managed_sse_enabled           = var.sqs_managed_sse_enabled
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds

  ################################################################################
  # Queue Policy
  ################################################################################

  create_queue_policy             = var.create_queue_policy
  queue_policy_statements         = var.queue_policy_statements
  source_queue_policy_documents   = var.source_queue_policy_documents
  override_queue_policy_documents = var.override_queue_policy_documents

  ################################################################################
  # Redrive Policy (main queue → DLQ)
  ################################################################################

  redrive_policy       = var.redrive_policy
  redrive_allow_policy = var.redrive_allow_policy

  ################################################################################
  # Dead Letter Queue (DLQ)
  ################################################################################

  create_dlq                     = var.create_dlq
  dlq_name                       = local.dlq_name
  dlq_message_retention_seconds  = var.dlq_message_retention_seconds
  dlq_delay_seconds              = var.dlq_delay_seconds
  dlq_receive_wait_time_seconds  = var.dlq_receive_wait_time_seconds
  dlq_visibility_timeout_seconds = var.dlq_visibility_timeout_seconds

  # DLQ FIFO
  dlq_content_based_deduplication = var.dlq_content_based_deduplication
  dlq_deduplication_scope         = var.dlq_deduplication_scope
  dlq_fifo_throughput_limit       = var.dlq_fifo_throughput_limit

  # DLQ Encryption
  dlq_sqs_managed_sse_enabled           = var.dlq_sqs_managed_sse_enabled
  dlq_kms_master_key_id                 = var.dlq_kms_master_key_id
  dlq_kms_data_key_reuse_period_seconds = var.dlq_kms_data_key_reuse_period_seconds

  ################################################################################
  # DLQ Policy
  ################################################################################

  create_dlq_queue_policy             = var.create_dlq_queue_policy
  dlq_queue_policy_statements         = var.dlq_queue_policy_statements
  source_dlq_queue_policy_documents   = var.source_dlq_queue_policy_documents
  override_dlq_queue_policy_documents = var.override_dlq_queue_policy_documents

  ################################################################################
  # DLQ Redrive Allow Policy
  ################################################################################

  create_dlq_redrive_allow_policy = var.create_dlq_redrive_allow_policy
  dlq_redrive_allow_policy        = var.dlq_redrive_allow_policy

  ################################################################################
  # Tags
  ################################################################################

  tags     = var.tags
  dlq_tags = var.dlq_tags
}
