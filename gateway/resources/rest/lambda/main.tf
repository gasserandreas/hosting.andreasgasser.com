variable "app_name" {}
variable "app_region" {}
variable "account_id" {}
variable "lambda_role" {}
variable "api" {}
variable "gateway_method" {}
variable "gateway_name" {}
variable "resource_path" {}
variable "auth_app_secret" {}
variable "auth_app_password" {}

resource "aws_lambda_function" "post_lambda" {
  filename         = "./rest-server/dist.zip"
  function_name    = "andreasgasser_com__${var.gateway_name}_rest"
  role             = "${var.lambda_role}"
  handler          = "index.rest"
  runtime          = "nodejs10.x"
  source_code_hash = "${filebase64sha256("./rest-server/dist.zip")}"
  memory_size = 512
  timeout = "10"

  environment {
    variables = {
      APP_SECRET = "${var.auth_app_secret}"
      APP_PASSWORD = "${var.auth_app_password}"
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.post_lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.app_region}:${var.account_id}:${var.api}/*/${var.gateway_method}${var.resource_path}"
}

output "arn" {
  value = "${aws_lambda_function.post_lambda.arn}"
}
