# Function
output "function_name" {
  description = "Lambda Name"
  value       = aws_lambda_function.lambda_function.function_name
}

output "function_arn" {
  description = "Lambda Arn"
  value       = aws_lambda_function.lambda_function.arn
}

output "qualified_arn" {
  description = "Lambda Arn"
  value       = aws_lambda_function.lambda_function.qualified_arn
}

output "version" {
  description = "Lambda Version"
  value       = aws_lambda_function.lambda_function.version
}

# Log Group
output "cloudwatch_loggroup_name" {
  description = "Log group name"
  value = try(aws_cloudwatch_log_group.cloudwatch_log_group[0].name, "")
}

output "cloudwatch_loggroup_arn" {
  description = "Log group arn"
  value = try(aws_cloudwatch_log_group.cloudwatch_log_group[0].arn, "")
}

# IAM Role
output "lambda_role_arn" {
  description = "The ARN of the IAM role created for the Lambda Function"
  value       = try(aws_iam_role.lambda[0].arn, "")
}

output "lambda_role_name" {
  description = "The name of the IAM role created for the Lambda Function"
  value       = try(aws_iam_role.lambda[0].name, "")
}

# API Gateway 
output "invoke_arn" {
  description = "ARN to be used for invoking Lambda Function from API Gateway"
  value       = aws_lambda_function.lambda_function.invoke_arn
}

output "lambda_function_name" {
  description = "The name of the primary Lambda function"
  value       = aws_lambda_function.lambda_function.function_name
}

# SNS Topic
output "sns_topic_arn" {
  description = "The ARN of the SNS topic for Lambda errors"
  value       = aws_sns_topic.lambda_error_sns.arn
}

# CloudWatch Alarm
output "cloudwatch_alarm_name" {
  description = "The name of the CloudWatch alarm for Lambda errors"
  value       = aws_cloudwatch_metric_alarm.lambda_error_alarm.alarm_name
}

# Slack Notifier Lambda Function
output "slack_notifier_lambda_function_name" {
  description = "The name of the Lambda function that posts to Slack"
  value       = aws_lambda_function.slack_notifier_lambda.function_name
}