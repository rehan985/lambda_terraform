locals {
  log_group_arn = try(aws_cloudwatch_log_group.cloudwatch_log_group[0].arn, var.existing_log_group_arn, "")

  policy_jsons = toset([
  for policy in var.policy_jsons: policy if var.lambda_role_arn == null
])
}

# Role
resource "aws_iam_role" "lambda" {
  count              = var.lambda_role_arn == null ? 1 : 0
  name               = "${var.resource_prefix}-${var.function_name}-ExecutionRole-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.lambda[0].json
}

data "aws_iam_policy_document" "lambda" {
  count = var.lambda_role_arn == null ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Cloudwatch policy
data "aws_iam_policy_document" "logs" {
  count = var.lambda_role_arn == null && var.attach_cloudwatch_logs_policy ? 1 : 0
  statement {
    effect = "Allow"
    actions = compact([
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ])
    resources = flatten([for _, v in ["%v:*", "%v:*:*"] : format(v, local.log_group_arn)])
  }
}

resource "aws_iam_policy" "logs" {
  count  = var.lambda_role_arn == null && var.attach_cloudwatch_logs_policy ? 1 : 0
  name   = "${var.resource_prefix}-${var.function_name}-ExecutionPolicy-Logs-${terraform.workspace}"
  policy = data.aws_iam_policy_document.logs[0].json
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "logs" {
  count      = var.lambda_role_arn == null && var.attach_cloudwatch_logs_policy ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.logs[0].arn
}


# Tracing Policy
data "aws_iam_policy" "tracing" {
  count = var.lambda_role_arn == null && var.attach_tracing_policy ? 1 : 0
  arn   = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_policy" "tracing" {
  count  = var.lambda_role_arn == null && var.attach_tracing_policy ? 1 : 0
  name   = "${var.resource_prefix}-${var.function_name}-ExecutionPolicy-Tracing-${terraform.workspace}"
  policy = data.aws_iam_policy.tracing[0].policy
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "tracing" {
  count      = var.lambda_role_arn == null && var.attach_tracing_policy ? 1 : 0
  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.tracing[0].arn
}

# Additional policies
resource "aws_iam_policy" "additional_policies" {
  for_each = local.policy_jsons
  name     = "${var.resource_prefix}-${var.function_name}-ExecutionPolicy-Additional${index(var.policy_jsons, each.value) + 1}-${terraform.workspace}"
  policy   = each.value
  tags     = local.tags
}

resource "aws_iam_role_policy_attachment" "additional_policies" {
  for_each   = local.policy_jsons
  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.additional_policies[each.key].arn
}

