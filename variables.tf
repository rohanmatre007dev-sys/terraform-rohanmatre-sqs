################################################################################
# General
################################################################################

variable "create" {
  description = "Whether to create SQS queue"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Queue
################################################################################

variable "name" {
  description = "This is the human-readable name of the queue. If omitted, Terraform will assign a random name. For FIFO queues the name must end with .fifo"
  type        = string
  default     = null
}

variable "use_name_prefix" {
  description = "Determines whether name is used as a prefix"
  type        = bool
  default     = false
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). Default is 30 seconds."
  type        = number
  default     = null

  validation {
    condition     = var.visibility_timeout_seconds == null || (var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200)
    error_message = "visibility_timeout_seconds must be between 0 and 43200 (12 hours)."
  }
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). Default is 345600 (4 days)."
  type        = number
  default     = null

  validation {
    condition     = var.message_retention_seconds == null || (var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600)
    error_message = "message_retention_seconds must be between 60 (1 minute) and 1209600 (14 days)."
  }
}

variable "max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 1048576 bytes (1024 KiB). Default is 262144 (256 KiB)."
  type        = number
  default     = null
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). Default is 0."
  type        = number
  default     = null

  validation {
    condition     = var.delay_seconds == null || (var.delay_seconds >= 0 && var.delay_seconds <= 900)
    error_message = "delay_seconds must be between 0 and 900 (15 minutes)."
  }
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds). Default is 0 (short polling)."
  type        = number
  default     = null

  validation {
    condition     = var.receive_wait_time_seconds == null || (var.receive_wait_time_seconds >= 0 && var.receive_wait_time_seconds <= 20)
    error_message = "receive_wait_time_seconds must be between 0 and 20."
  }
}

################################################################################
# FIFO Queue
################################################################################

variable "fifo_queue" {
  description = "Boolean designating a FIFO queue. FIFO queue names must end in .fifo"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO queues. Only applicable when fifo_queue = true"
  type        = bool
  default     = null
}

variable "deduplication_scope" {
  description = "Specifies whether message deduplication occurs at the message group or queue level. Valid values: messageGroup, queue. Only applicable for FIFO queues."
  type        = string
  default     = null
}

variable "fifo_throughput_limit" {
  description = "Specifies whether the FIFO queue throughput quota applies to the entire queue or per message group. Valid values: perQueue, perMessageGroupId. Only applicable for FIFO queues."
  type        = string
  default     = null
}

################################################################################
# Encryption
################################################################################

variable "sqs_managed_sse_enabled" {
  description = "Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys. Automatically set to false when kms_master_key_id is provided."
  type        = bool
  default     = true
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK. Setting this disables sqs_managed_sse_enabled."
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = "The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. An integer representing seconds, between 60 seconds (1 minute) and 86,400 seconds (24 hours). Default is 300."
  type        = number
  default     = null
}

################################################################################
# Queue Policy
################################################################################

variable "create_queue_policy" {
  description = "Whether to create SQS queue policy"
  type        = bool
  default     = false
}

variable "queue_policy_statements" {
  description = "A map of IAM policy statements for custom permission usage"
  type = map(object({
    sid           = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    effect        = optional(string, "Allow")
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
  default = null
}

variable "source_queue_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. Statements must have unique sids"
  type        = list(string)
  default     = []
}

variable "override_queue_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank sids will override statements with the same sid"
  type        = list(string)
  default     = []
}

################################################################################
# Redrive Policy
################################################################################

variable "redrive_policy" {
  description = "The JSON policy to set up the Dead Letter Queue redrive. Note: maxReceiveCount must be an integer (5), not a string (\"5\"). Default is 5 when create_dlq = true."
  type        = any
  default     = {}
}

variable "redrive_allow_policy" {
  description = "The JSON policy to set up the Dead Letter Queue redrive permission"
  type        = any
  default     = {}
}

################################################################################
# Dead Letter Queue (DLQ)
################################################################################

variable "create_dlq" {
  description = "Determines whether to create SQS dead letter queue. When true, dlq_name is auto-derived from name as '<name>-dlq' (or '<name>-dlq.fifo' for FIFO) via locals.tf."
  type        = bool
  default     = false
}

variable "dlq_name" {
  description = "The human-readable name of the dead letter queue. Auto-derived from name when not set (see locals.tf)."
  type        = string
  default     = null
}

variable "dlq_message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message in the DLQ. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). Default is 1209600 (14 days) for DLQs."
  type        = number
  default     = null
}

variable "dlq_delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the DLQ will be delayed. An integer from 0 to 900 (15 minutes)."
  type        = number
  default     = null
}

variable "dlq_receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive in the DLQ (long polling). An integer from 0 to 20 (seconds)."
  type        = number
  default     = null
}

variable "dlq_visibility_timeout_seconds" {
  description = "The visibility timeout for the DLQ. An integer from 0 to 43200 (12 hours)."
  type        = number
  default     = null
}

variable "dlq_tags" {
  description = "A mapping of additional tags to assign to the dead letter queue"
  type        = map(string)
  default     = {}
}

################################################################################
# DLQ FIFO
################################################################################

variable "dlq_content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO DLQ. Only applicable when fifo_queue = true."
  type        = bool
  default     = null
}

variable "dlq_deduplication_scope" {
  description = "Specifies whether message deduplication occurs at the message group or queue level for the DLQ. Only applicable for FIFO queues."
  type        = string
  default     = null
}

variable "dlq_fifo_throughput_limit" {
  description = "Specifies whether the DLQ FIFO queue throughput quota applies to the entire queue or per message group. Only applicable for FIFO queues."
  type        = string
  default     = null
}

################################################################################
# DLQ Encryption
################################################################################

variable "dlq_sqs_managed_sse_enabled" {
  description = "Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys for the DLQ"
  type        = bool
  default     = true
}

variable "dlq_kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for the DLQ"
  type        = string
  default     = null
}

variable "dlq_kms_data_key_reuse_period_seconds" {
  description = "The length of time, in seconds, for which Amazon SQS can reuse a data key for the DLQ. Between 60 seconds and 86,400 seconds."
  type        = number
  default     = null
}

################################################################################
# DLQ Policy
################################################################################

variable "create_dlq_queue_policy" {
  description = "Whether to create SQS queue policy for the DLQ"
  type        = bool
  default     = false
}

variable "dlq_queue_policy_statements" {
  description = "A map of IAM policy statements for the DLQ"
  type = map(object({
    sid           = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    effect        = optional(string, "Allow")
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
  default = null
}

variable "source_dlq_queue_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document for the DLQ. Statements must have unique sids"
  type        = list(string)
  default     = []
}

variable "override_dlq_queue_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document for the DLQ. In merging, statements with non-blank sids will override statements with the same sid"
  type        = list(string)
  default     = []
}

################################################################################
# DLQ Redrive Allow Policy
################################################################################

variable "create_dlq_redrive_allow_policy" {
  description = "Determines whether to create a redrive allow policy for the dead letter queue"
  type        = bool
  default     = true
}

variable "dlq_redrive_allow_policy" {
  description = "The JSON policy to set up the DLQ redrive allow permission"
  type        = any
  default     = {}
}
