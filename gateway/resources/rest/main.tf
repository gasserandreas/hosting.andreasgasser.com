variable "api_parent_id" {}
variable "rest_api_id" {}
variable "app_region" {}
variable "account_id" {}
variable "app_name" {}
variable "lambda_role" {}
variable "auth_app_secret" {}
variable "auth_app_password" {}
variable "api_app_email" {}


# user resources for get (list), post, put and delete
resource "aws_api_gateway_resource" "rest" {
  path_part   = "rest"
  parent_id   = "${var.api_parent_id}"
  rest_api_id = "${var.rest_api_id}"
}

# options / CORS configuration for rest
resource "aws_api_gateway_method" "options_method_rest" {
  rest_api_id   = "${var.rest_api_id}"
  resource_id   = "${aws_api_gateway_resource.rest.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200_rest" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_resource.rest.id}"
  http_method = "${aws_api_gateway_method.options_method_rest.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = ["aws_api_gateway_method.options_method_rest"]
}

resource "aws_api_gateway_integration" "options_integration_rest" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_resource.rest.id}"
  http_method = "${aws_api_gateway_method.options_method_rest.http_method}"
  type        = "MOCK"
  depends_on  = ["aws_api_gateway_method.options_method_rest"]

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response_rest" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${aws_api_gateway_resource.rest.id}"
  http_method = "${aws_api_gateway_method.options_method_rest.http_method}"
  status_code = "${aws_api_gateway_method_response.options_200_rest.status_code}"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token','X-Apollo-Tracing'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,GET,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  # response_parameters = "${local.method_response_parameters}"

  depends_on = ["aws_api_gateway_method_response.options_200_rest"]
}

# integration
resource "aws_api_gateway_method" "rest" {
  rest_api_id   = "${var.rest_api_id}"
  resource_id   = "${aws_api_gateway_resource.rest.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "rest_response_200" {
  rest_api_id           = "${var.rest_api_id}"
  resource_id           = "${aws_api_gateway_resource.rest.id}"
  http_method           = "${aws_api_gateway_method.rest.http_method}"
  status_code           = "200"
  response_parameters = {
      "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on            = ["aws_api_gateway_method.rest", "aws_api_gateway_integration.rest"]
}

resource "aws_api_gateway_integration" "rest" {
  rest_api_id             = "${var.rest_api_id}"
  resource_id             = "${aws_api_gateway_resource.rest.id}"
  http_method             = "${aws_api_gateway_method.rest.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.app_region}:lambda:path/2015-03-31/functions/${module.rest_lambda.arn}/invocations"
}

# get lambda
module "rest_lambda" {
  source = "./lambda"

  app_name       = "${var.app_name}"
  app_region     = "${var.app_region}"
  account_id     = "${var.account_id}"
  lambda_role    = "${var.lambda_role}"
  api            = "${var.rest_api_id}"
  gateway_method = "${aws_api_gateway_method.rest.http_method}"
  gateway_name   = "${aws_api_gateway_method.rest.http_method}"
  resource_path  = "${aws_api_gateway_resource.rest.path}"
  auth_app_secret = "${var.auth_app_secret}"
  auth_app_password = "${var.auth_app_password}"
  api_app_email = "${var.api_app_email}"
}