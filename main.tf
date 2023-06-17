# Variables
variable "app_region" {}

variable "account_id" {}

variable "app_name" {}

variable "prod_root_domain_name" {}

variable "prod_www_domain_name" {}

variable "credentials_file" {}

variable "profile" {}

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