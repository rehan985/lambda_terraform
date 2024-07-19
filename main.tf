data "aws_caller_identity" "current" {}

locals {
  tags = merge({
    Author = data.aws_caller_identity.current.user_id
    Time   = timestamp()
  }, var.tags)
}

resource "aws_lambda_function" "lambda_function" {
  function_name                  = "${var.resource_prefix}-${var.function_name}-${terraform.workspace}"
  role                           = var.lambda_role_arn != null ? var.lambda_role_arn : aws_iam_role.lambda[0].arn
  description                    = var.description

  architectures                  = var.architectures
  layers                         = var.layers
  package_type                   = var.package_type
  runtime                        = var.runtime
  image_uri                      = var.image_uri
  filename                       = var.filename
  source_code_hash               = var.source_code_hash
  s3_bucket                      = var.s3bucket
  s3_key                         = var.s3key
  handler                        = var.handler
  publish                        = var.publish
  memory_size                    = var.memory_size
  timeout                        = var.timeout

  dynamic "ephemeral_storage"    {
    for_each = var.ephemeral_storage_size != null ? [1] : []
    content {
      size = var.ephemeral_storage_size
    }
  }

  dynamic "tracing_config"    {
    for_each = var.tracing_config_mode != null ? [1] : []
    content {
      mode = var.tracing_config_mode
    }
  }

  reserved_concurrent_executions = var.reserved_concurrent_executions

  dynamic "environment" {
    for_each = var.environment == null ? [] : [var.environment]
    content {
      variables = var.environment
    }
  }

  dynamic "snap_start" {
    for_each = var.enable_snap_start != false ? [1] : []
    content {
      apply_on = "PublishedVersions"
    }    
  }

  logging_config {
    log_format = var.log_format
  }
  tags = local.tags
}

resource "aws_lambda_function_event_invoke_config" "event_invoke_config" {
  count                        = var.create_event_invoke_config ? 1 : 0
  function_name                = aws_lambda_function.lambda_function.function_name
  maximum_event_age_in_seconds = var.event_age
  maximum_retry_attempts       = var.retry_attempts
}

resource "aws_lambda_provisioned_concurrency_config" "concurrency_config" {
  count                             = var.concurrent_executions > "0" ? 1 : 0
  function_name                     = aws_lambda_function.lambda_function.function_name
  provisioned_concurrent_executions = var.concurrent_executions
  qualifier                         = aws_lambda_function.lambda_function.version
  depends_on = [
    aws_lambda_function.lambda_function
  ]
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  count             = var.existing_log_group_arn == null ? 1 : 0
  name              = format("/aws/lambda/%s", "${var.resource_prefix}-${var.function_name}-${terraform.workspace}")
  retention_in_days = var.log_retention
  tags              = local.tags
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "${var.lambda_function_name}-errors"
  alarm_description   = "Trigger a notification if the Lambda function experiences any errors"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  statistic           = "Sum"
  period              = "300"
  evaluation_periods  = "1"
  threshold           = "1"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  dimensions = {
    FunctionName = aws_lambda_function.lambda_function.function_name
  }
  alarm_actions = [aws_sns_topic.lambda_error_sns.arn]
}

resource "aws_sns_topic" "lambda_error_sns" {
  name = "${var.lambda_function_name}-error-sns"
}

resource "aws_sns_topic_subscription" "lambda_error_sns_subscription" {
  topic_arn = aws_sns_topic.lambda_error_sns.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notifier_lambda.arn
}

resource "aws_lambda_function" "slack_notifier_lambda" {
  filename         = "path/to/your/slack_notifier.zip"
  function_name    = "${var.lambda_function_name}-slack-notifier"
  role             = aws_iam_role.lambda_role.arn
  handler          = "slack_notifier.handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("path/to/your/slack_notifier.zip")

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }
}
