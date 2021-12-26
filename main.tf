# Variables
variable "app_region" {}

variable "account_id" {}

variable "app_name" {}

variable "prod_root_domain_name" {}

variable "prod_www_domain_name" {}

variable "test_root_domain_name" {}

variable "test_www_domain_name" {}

variable "storybook_root_domain_name" {}

variable "storybook_www_domain_name" {}

variable "credentials_file" {}

variable "profile" {}

variable "api_domain_name" {}

variable "api_version" {}

variable "auth_app_secret" {}

variable "auth_app_password" {}

variable "api_stage" {}

variable "api_app_email" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# provider
provider "aws" {
  region = var.app_region
  # shared_credentials_file = var.credentials_file
  # profile                 = var.profile
}

# prod environment
module "prod_certificate" {
  source           = "./acm-certificate"
  root_domain_name = var.prod_root_domain_name
  www_domain_name  = var.prod_www_domain_name
}

module "prod_bucket" {
  source = "./s3-hosting"

  app_region       = var.app_region
  account_id       = var.account_id
  app_name         = var.app_name
  root_domain_name = var.prod_root_domain_name
}

module "prod_cloudfront" {
  source                     = "./cloudfront"
  root_domain_name           = var.prod_root_domain_name
  www_domain_name            = var.prod_www_domain_name
  s3_bucket_website_endpoint = module.prod_bucket.website_endpoint
  acm_certification_arn      = module.prod_certificate.arn_hosting
}

# storybook environment
module "storybook_certificate" {
  source           = "./acm-certificate"
  root_domain_name = var.storybook_root_domain_name
  www_domain_name  = var.storybook_www_domain_name
}

module "storybook_bucket" {
  source = "./s3-hosting"

  app_region       = var.app_region
  account_id       = var.account_id
  app_name         = var.app_name
  root_domain_name = var.storybook_root_domain_name
}

module "storybook_cloudfront" {
  source                     = "./cloudfront"
  root_domain_name           = var.storybook_root_domain_name
  www_domain_name            = var.storybook_www_domain_name
  s3_bucket_website_endpoint = module.storybook_bucket.website_endpoint
  acm_certification_arn      = module.storybook_certificate.arn_hosting
}

# api implementation
module "gateway" {
  source = "./gateway"

  app_region        = var.app_region
  account_id        = var.account_id
  app_name          = var.app_name
  api_domain_name   = var.api_domain_name
  api_version       = var.api_version
  api_stage         = var.api_stage
  auth_app_secret   = var.auth_app_secret
  auth_app_password = var.auth_app_password
  api_app_email     = var.api_app_email
}

# test environment
module "test_certificate" {
  source           = "./acm-certificate"
  root_domain_name = var.test_root_domain_name
  www_domain_name  = var.test_www_domain_name
}

module "test_bucket" {
  source = "./s3-hosting"

  app_region       = var.app_region
  account_id       = var.account_id
  app_name         = var.app_name
  root_domain_name = var.test_root_domain_name
}

module "test_cloudfront" {
  source                     = "./cloudfront"
  root_domain_name           = var.test_root_domain_name
  www_domain_name            = var.test_www_domain_name
  s3_bucket_website_endpoint = module.test_bucket.website_endpoint
  acm_certification_arn      = module.test_certificate.arn_hosting
}

# utils bucket
module "utils" {
  source           = "./s3-bucket"
  app_region       = var.app_region
  account_id       = var.account_id
  app_name         = var.app_name
  root_domain_name = var.prod_root_domain_name
  bucket_name      = "utils"
}

# define code build role

# develop branch
module "codebuild_role_develop" {
  source     = "./codebuild-role"
  app_region = var.app_region
  account_id = var.account_id
  app_name   = var.app_name
  role_name  = "develop"
}

# define access policies
resource "aws_iam_role_policy" "develop" {
  role = module.codebuild_role_develop.role_name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${module.test_bucket.bucket_arn}",
        "${module.test_bucket.bucket_arn}/*",
        "${module.utils.bucket_arn}",
        "${module.utils.bucket_arn}/*"
      ]
    }
  ]
}
POLICY
}

# master branch
module "codebuild_role_master" {
  source     = "./codebuild-role"
  app_region = var.app_region
  account_id = var.account_id
  app_name   = var.app_name
  role_name  = "master"
}

# define access policies
resource "aws_iam_role_policy" "master" {
  role = module.codebuild_role_master.role_name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${module.prod_bucket.bucket_arn}",
        "${module.prod_bucket.bucket_arn}/*",
        "${module.storybook_bucket.bucket_arn}",
        "${module.storybook_bucket.bucket_arn}/*",
        "${module.utils.bucket_arn}",
        "${module.utils.bucket_arn}/*"
      ]
    }
  ]
}
POLICY
}
