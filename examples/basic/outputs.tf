output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = module.sqs.queue_arn
}

output "queue_url" {
  description = "The URL of the SQS queue"
  value       = module.sqs.queue_url
}

output "queue_name" {
  description = "The name of the SQS queue"
  value       = module.sqs.queue_name
}

output "dead_letter_queue_arn" {
  description = "The ARN of the dead letter queue"
  value       = module.sqs.dead_letter_queue_arn
}

output "dead_letter_queue_url" {
  description = "The URL of the dead letter queue"
  value       = module.sqs.dead_letter_queue_url
}

output "dead_letter_queue_name" {
  description = "The name of the dead letter queue"
  value       = module.sqs.dead_letter_queue_name
}
