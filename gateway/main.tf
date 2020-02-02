variable "app_region" {}
variable "account_id" {}
variable "app_name" {}
variable "api_domain_name" {}
variable "api_version" {}
variable "api_stage" {}
variable "auth_app_secret" {}
variable "auth_app_password" {}
variable "api_app_email" {}


# create api
resource "aws_api_gateway_rest_api" "api" {
  name = "${var.app_name}_api"
}

# resources
module "resource_rest" {
  source = "./resources/rest"

  api_parent_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  app_region    = "${var.app_region}"
  account_id    = "${var.account_id}"
  app_name      = "${var.app_name}"
  lambda_role   = "${aws_iam_role.lambda_role.arn}"

  auth_app_secret = "${var.auth_app_secret}"
  auth_app_password = "${var.auth_app_password}"
  api_app_email = "${var.api_app_email}"
}

# lambda execution role
resource "aws_iam_role" "lambda_role" {
  name = "${var.app_name}_lambda_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

# cloudwatch log group 
data "aws_iam_policy_document" "cloudwatch_log_group_lambda" {
  statement {
    actions = [
      "logs:PutLogEvents",    # take care of action order
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]

    resources = ["*"]
  }
}

# attach cloudwatch log group to lambda role
resource "aws_iam_role_policy" "lambda_cloudwatch_log_group" {
  name   = "${var.app_name}_cloudwatch-log-group"
  role   = "${aws_iam_role.lambda_role.name}"
  policy = "${data.aws_iam_policy_document.cloudwatch_log_group_lambda.json}"
}
# deploy api
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    "module.resource_rest",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "${var.api_stage}"
}

# output api
output "invoke_url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}"
}

output "rest_lambda_role_name" {
  value = "${aws_iam_role.lambda_role.name}"
}
