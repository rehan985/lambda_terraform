# Function
variable "resource_prefix" {
  type    = string
  default = null
}

variable "function_name" {
  description = "A unique name for the Lambda Function"
  type        = string
}

variable "description" {
  description = "Function description. Optional"
  type        = string
  default     = null
}

variable "lambda_role_arn" {
  description = "IAM role ARN attached to the Lambda Function. This governs both who / what can invoke your Lambda Function, as well as what resources our Lambda Function has access to. See Lambda Permission Model for more details."
  type        = string
  default     = null
}

variable "architectures" {
  description = "Instruction set architecture for your Lambda function"
  type        = list(string)
  default     = null
}

variable "package_type" {
  description = "Lambda deployment package type"
  type        = string
  default     = "Zip"
}

variable "image_uri" {
  description = "ECR image URI containing the function deployment package"
  type        = string
  default     = null
}

variable "s3bucket" {
  description = "Bucket containing the deployment code"
  type        = string
  default     = null
}

variable "s3key" {
  description = "object name in s3 bucket containing the deployment code"
  type        = string
  default     = null  
}

variable "handler" {
  description = "Function entrypoint in the code"
  type        = string
  default     = null  
}

variable "filename" {
  description = "Path to the deployment package"
  type        = string
  default     = null  
}

variable "source_code_hash" {
  description = "Source code hash of the package, to be used together with 'filename' variable"
  type        = string
  default     = null  
}

variable "runtime" {
  description = "Runtime for the code"
  type        = string
  default     = null
}

variable "ephemeral_storage_size" {
  description = "Ephemeral storage for the lambda"
  type        = number
  default     = null
}

variable "tracing_config_mode" {
  description = "Whether to sample and trace a subset of incoming requests with AWS X-Ray"
  type        = string
  default     = null
}

variable "layers" {
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function"
  type        = list(string)
  default     = [] 
}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version"
  type        = bool
  default     = true
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds"
  type        = number
  default     = 5
}

variable "reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this lambda function"
  type        = number
  default     = null
}

variable "environment" {
  description = "The Lambda environment configuration settings"
  type        = map(string)
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "tags to associate with the ECS cluster"
  default     = {}
}

# Event Invoke Config
variable "create_event_invoke_config" {
  description = "Controls whether event configuration for Lambda Function should be created"
  type        = bool
  default     = false
}


variable "event_age" {
  description = "Maximum age of a request that Lambda sends to a function for processing in seconds"
  type        = number
  default     = 100
}

variable "retry_attempts" {
  description = "Maximum number of times to retry when the function returns an error"
  type        = number
  default     = 0
}

variable "enable_snap_start" {
  description = "Snap start settings for low-latency startups. This feature is currently only supported for java11, java17 and java21 runtimes"
  type        = bool
  default     = false
}

# Concurrency Config
variable "concurrent_executions" {
  description = "Amount of capacity to allocate"
  type        = number
}

# Cloudwatch
variable "existing_log_group_arn" {
  description = "ARN of the existing CloudWatch log group where logs will be saved"
  type        = string
  default     = null
}

variable "log_retention" {
  description = "Specifies the number of days you want to retain log events in the specified log group"
  type        = number
  default     = 1
}

variable "log_format" {
  description = "Select between Text and structured JSON format for your function's logs"
  type        = string
  default     = "Text"
}

# IAM
variable "attach_cloudwatch_logs_policy" {
  description = "Controls whether CloudWatch Logs policy should be added to IAM role for Lambda Function"
  type        = bool
  default     = true
}

variable "attach_tracing_policy" {
  description = "Controls whether X-Ray tracing policy should be added to IAM role for Lambda Function"
  type        = bool
  default     = true
}

variable "policy_jsons" {
  description = "List of additional policy documents to attach to Lambda Function role"
  type        = list(string)
  default     = []
}

variable "slack_webhook_url" {
  description = "The Slack Webhook URL for sending alerts"
  type        = string
}

variable "alarm_threshold" {
  description = "The threshold for the error count alarm"
  type        = number
  default     = 1
}

variable "alarm_evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold"
  type        = number
  default     = 1
}

variable "alarm_period" {
  description = "The period, in seconds, over which the specified statistic is applied"
  type        = number
  default     = 300
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}