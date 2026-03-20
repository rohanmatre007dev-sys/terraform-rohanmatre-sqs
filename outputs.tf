################################################################################
# Main Queue
################################################################################

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = module.sqs.queue_arn
}

output "queue_arn_static" {
  description = "The ARN of the SQS queue. Use this to avoid cycle errors between resources (e.g., Step Functions)"
  value       = module.sqs.queue_arn_static
}

output "queue_id" {
  description = "The URL for the created Amazon SQS queue"
  value       = module.sqs.queue_id
}

output "queue_url" {
  description = "Same as queue_id: The URL for the created Amazon SQS queue"
  value       = module.sqs.queue_url
}

output "queue_name" {
  description = "The name of the SQS queue"
  value       = module.sqs.queue_name
}

################################################################################
# Dead Letter Queue
################################################################################

output "dead_letter_queue_arn" {
  description = "The ARN of the dead letter SQS queue"
  value       = module.sqs.dead_letter_queue_arn
}

output "dead_letter_queue_arn_static" {
  description = "The ARN of the dead letter SQS queue. Use this to avoid cycle errors between resources (e.g., Step Functions)"
  value       = module.sqs.dead_letter_queue_arn_static
}

output "dead_letter_queue_id" {
  description = "The URL for the created dead letter Amazon SQS queue"
  value       = module.sqs.dead_letter_queue_id
}

output "dead_letter_queue_url" {
  description = "Same as dead_letter_queue_id: The URL for the created dead letter Amazon SQS queue"
  value       = module.sqs.dead_letter_queue_url
}

output "dead_letter_queue_name" {
  description = "The name of the dead letter SQS queue"
  value       = module.sqs.dead_letter_queue_name
}
