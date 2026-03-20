################################################################################
# Standard Queue
################################################################################

output "queue_arn" {
  description = "The ARN of the standard SQS queue"
  value       = module.sqs_standard.queue_arn
}

output "queue_arn_static" {
  description = "The static ARN of the standard SQS queue (use to avoid cycle errors)"
  value       = module.sqs_standard.queue_arn_static
}

output "queue_id" {
  description = "The URL of the standard SQS queue"
  value       = module.sqs_standard.queue_id
}

output "queue_url" {
  description = "The URL of the standard SQS queue (clone of queue_id)"
  value       = module.sqs_standard.queue_url
}

output "queue_name" {
  description = "The name of the standard SQS queue"
  value       = module.sqs_standard.queue_name
}

output "dead_letter_queue_arn" {
  description = "The ARN of the dead letter queue"
  value       = module.sqs_standard.dead_letter_queue_arn
}

output "dead_letter_queue_arn_static" {
  description = "The static ARN of the dead letter queue (use to avoid cycle errors)"
  value       = module.sqs_standard.dead_letter_queue_arn_static
}

output "dead_letter_queue_url" {
  description = "The URL of the dead letter queue"
  value       = module.sqs_standard.dead_letter_queue_url
}

output "dead_letter_queue_name" {
  description = "The name of the dead letter queue"
  value       = module.sqs_standard.dead_letter_queue_name
}

################################################################################
# FIFO Queue
################################################################################

output "fifo_queue_arn" {
  description = "The ARN of the FIFO SQS queue"
  value       = module.sqs_fifo.queue_arn
}

output "fifo_queue_url" {
  description = "The URL of the FIFO SQS queue"
  value       = module.sqs_fifo.queue_url
}

output "fifo_queue_name" {
  description = "The name of the FIFO SQS queue"
  value       = module.sqs_fifo.queue_name
}

output "fifo_dead_letter_queue_arn" {
  description = "The ARN of the FIFO dead letter queue"
  value       = module.sqs_fifo.dead_letter_queue_arn
}

output "fifo_dead_letter_queue_url" {
  description = "The URL of the FIFO dead letter queue"
  value       = module.sqs_fifo.dead_letter_queue_url
}

output "fifo_dead_letter_queue_name" {
  description = "The name of the FIFO dead letter queue"
  value       = module.sqs_fifo.dead_letter_queue_name
}
