# Variables
variable "app_region" {}

variable "account_id" {}

variable "app_name" {}

variable "root_domain_name" {}

variable "www_domain_name" {}

variable "credentials_file" {}

variable "profile" {}

# provider
provider "aws" {
  region = "${var.app_region}"
  shared_credentials_file = "${var.credentials_file}"
  profile                 = "${var.profile}"
}

module "certificate" {
  source           = "./acm-certificate"
  root_domain_name = "${var.root_domain_name}"
  www_domain_name  = "${var.www_domain_name}"
}

module "bucket" {
  source = "./s3"

  app_region       = "${var.app_region}"
  account_id       = "${var.account_id}"
  app_name         = "${var.app_name}"
  root_domain_name = "${var.root_domain_name}"
}

module "cloudfront" {
  source                     = "./cloudfront"
  root_domain_name           = "${var.root_domain_name}"
  www_domain_name            = "${var.www_domain_name}"
  s3_bucket_website_endpoint = "${module.bucket.website_endpoint}"
  acm_certification_arn      = "${module.certificate.arn_hosting}"
}