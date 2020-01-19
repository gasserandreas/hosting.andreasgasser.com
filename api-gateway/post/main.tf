variable "app_name" {}
variable "app_region" {}
variable "account_id" {}
variable "lambda_role" {}
variable "api" {}
variable "gateway_method" {}
variable "gateway_name" {}
variable "resource_path" {}

resource "aws_lambda_function" "post_lambda" {
  filename         = "./api-gateway/post/post.zip"
  function_name    = "gasserandreas_com_${var.gateway_name}_post"
  role             = "${var.lambda_role}"
  handler          = "index.handler"
  runtime          = "nodejs10.x"
  # source_code_hash = "${base64sha256(file("./api-gateway/post/post.zip"))}"
  source_code_hash = "${filebase64sha256("./api-gateway/post/post.zip")}"
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