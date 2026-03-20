locals {
  # Auto-derive DLQ name from main queue name when not explicitly set
  # FIFO queues require names ending in .fifo — preserve the suffix on the DLQ
  dlq_name = var.dlq_name != null ? var.dlq_name : (
    var.name != null ? (
      var.fifo_queue
      ? "${trimsuffix(var.name, ".fifo")}-dlq.fifo"
      : "${var.name}-dlq"
    ) : null
  )

  # Derived: is this a FIFO queue?
  is_fifo = var.fifo_queue

  # Guard: content_based_deduplication only applies to FIFO queues
  effective_content_based_deduplication = local.is_fifo ? var.content_based_deduplication : null

  # Guard: deduplication_scope only applies to FIFO queues
  effective_deduplication_scope = local.is_fifo ? var.deduplication_scope : null

  # Guard: fifo_throughput_limit only applies to FIFO queues
  effective_fifo_throughput_limit = local.is_fifo ? var.fifo_throughput_limit : null

  # Derived: KMS and SQS-managed SSE are mutually exclusive
  # If kms_master_key_id is set, sqs_managed_sse_enabled should be false
  effective_sqs_managed_sse_enabled = var.kms_master_key_id != null ? false : var.sqs_managed_sse_enabled
}
