# terraform-rohanmatre-sqs

Terraform wrapper module for [terraform-aws-modules/sqs/aws](https://registry.terraform.io/modules/terraform-aws-modules/sqs/aws/latest).

This module exposes the full variable surface of the upstream SQS module with sensible defaults, input validations for queue parameters, and `locals.tf` guard-rails — including automatic DLQ name derivation, KMS/SSE mutual exclusion enforcement, and FIFO-specific setting guards.

---

## Usage

### Simple Standard Queue

```hcl
module "sqs" {
  source = "../../"

  name                       = "my-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400   # 1 day
  receive_wait_time_seconds  = 20      # long polling

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}
```

### Queue with Dead Letter Queue

```hcl
module "sqs" {
  source = "../../"

  name       = "my-queue"
  create_dlq = true   # DLQ auto-named "my-queue-dlq" via locals.tf

  redrive_policy = {
    maxReceiveCount = 5  # integer, not string
  }

  tags = { Terraform = "true", Environment = "prod" }
}
```

### FIFO Queue with DLQ

```hcl
module "sqs" {
  source = "../../"

  name                        = "my-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  fifo_throughput_limit       = "perMessageGroupId"

  create_dlq = true   # DLQ auto-named "my-queue-dlq.fifo" via locals.tf

  redrive_policy = {
    maxReceiveCount = 3
  }

  tags = { Terraform = "true", Environment = "prod" }
}
```

### Encrypted Queue with Customer KMS Key

```hcl
module "sqs" {
  source = "../../"

  name              = "encrypted-queue"
  kms_master_key_id = "arn:aws:kms:us-east-1:012345678901:key/mrk-xxxxxxxxxxxxxxxx"
  # sqs_managed_sse_enabled is auto-disabled by locals.tf when kms_master_key_id is set
  kms_data_key_reuse_period_seconds = 3600

  tags = { Terraform = "true", Environment = "prod" }
}
```

### Queue with SNS Policy (allow SNS to publish)

```hcl
module "sqs" {
  source = "../../"

  name                = "sns-subscriber"
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
  }

  tags = { Terraform = "true", Environment = "prod" }
}
```

---

## Conditional Creation

| Variable | Default | Purpose |
|---|---|---|
| `create` | `true` | Toggle all resources |
| `create_dlq` | `false` | Toggle dead letter queue |
| `create_queue_policy` | `false` | Toggle queue policy |
| `create_dlq_queue_policy` | `false` | Toggle DLQ policy |
| `create_dlq_redrive_allow_policy` | `true` | Toggle DLQ redrive allow policy |

---

## Important Notes

- **FIFO queues** require names ending in `.fifo`. `content_based_deduplication`, `deduplication_scope`, and `fifo_throughput_limit` only apply to FIFO queues.
- **DLQ auto-naming**: when `create_dlq = true` and `dlq_name` is not set, `locals.tf` derives the DLQ name as `<name>-dlq` (or `<name>-dlq.fifo` for FIFO queues).
- **KMS vs SQS-managed SSE are mutually exclusive**: setting `kms_master_key_id` automatically disables `sqs_managed_sse_enabled` via `locals.tf`.
- **`redrive_policy.maxReceiveCount`** must be an integer (`5`), not a string (`"5"`) — the upstream provider enforces this.
- **`queue_arn_static` vs `queue_arn`**: use `queue_arn_static` when referencing the queue ARN in other resources that would create a dependency cycle (e.g., Step Functions state machines).

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.7 |
| aws | >= 6.28 |

## Inputs

See [variables.tf](./variables.tf) for the full list. All variables are optional.

| Variable | Default | Description |
|---|---|---|
| `name` | `null` | Queue name (random if omitted) |
| `fifo_queue` | `false` | Create a FIFO queue (name must end in `.fifo`) |
| `create_dlq` | `false` | Create a dead letter queue |
| `sqs_managed_sse_enabled` | `true` | SQS-managed SSE (auto-disabled when KMS key is set) |
| `kms_master_key_id` | `null` | Customer KMS key for encryption |
| `visibility_timeout_seconds` | `null` | Message visibility timeout (0–43200) |
| `message_retention_seconds` | `null` | Message retention (60–1209600) |
| `receive_wait_time_seconds` | `null` | Long polling wait time (0–20) |
| `create_queue_policy` | `false` | Create queue policy |
| `redrive_policy` | `{}` | DLQ redrive config (maxReceiveCount must be integer) |

## Outputs

| Output | Description |
|--------|-------------|
| `queue_arn` | ARN of the SQS queue |
| `queue_arn_static` | Static ARN (use to avoid cycle errors) |
| `queue_id` | URL of the SQS queue |
| `queue_url` | URL of the SQS queue (clone of queue_id) |
| `queue_name` | Name of the SQS queue |
| `dead_letter_queue_arn` | ARN of the DLQ |
| `dead_letter_queue_arn_static` | Static ARN of the DLQ |
| `dead_letter_queue_id` | URL of the DLQ |
| `dead_letter_queue_url` | URL of the DLQ (clone of dead_letter_queue_id) |
| `dead_letter_queue_name` | Name of the DLQ |

## License

Apache-2.0 Licensed.
