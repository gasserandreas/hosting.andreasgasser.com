# Variables
variable "app_region" {}

variable "account_id" {}

variable "app_name" {}

variable "root_domain_name" {}

resource "aws_s3_bucket" "static_bucket" {
  // bucket name with account id prefix
  bucket = "${var.account_id}-${var.root_domain_name}"

  // Because we want our site to be available on the internet, we set this so
  // anyone can read this bucket.
  # acl = "public-read"

  // We also need to create a policy that allows anyone to view the content.
  // This is basically duplicating what we did in the ACL but it's required by
  // AWS. This post: http://amzn.to/2Fa04ul explains why.
#   policy = <<POLICY
# {
#   "Version":"2012-10-17",
#   "Statement":[
#     {
#       "Sid":"PublicReadGetObjectTest",
#       "Effect":"Allow",
#       "Principal": {
#          "AWS": "*"
#       },
#       "Action": "s3:GetObject",
#       "Resource":["arn:aws:s3:::${var.account_id}-${var.root_domain_name}/*"]
#     }
#   ]
# }
# POLICY

#   // S3 understands what it means to host a website.
#   website {
#     // Here we tell S3 what to use when a request comes in to the root
#     index_document = "index.html"

#     // The page to serve up if a request results in an error or a non-existing
#     // page.
#     error_document = "index.html"
#   }
}

resource "aws_s3_bucket_ownership_controls" "static_bucket" {
  bucket = aws_s3_bucket.static_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "static_bucket" {
  bucket = aws_s3_bucket.static_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "static_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.static_bucket,
    aws_s3_bucket_public_access_block.static_bucket,
  ]

  bucket = aws_s3_bucket.static_bucket.id
  acl    = "public-read"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.static_bucket.arn}"
}

output "bucket_id" {
  value = "${aws_s3_bucket.static_bucket.id}"
}

output "website_endpoint" {
  value = "${aws_s3_bucket.static_bucket.website_endpoint}"
}
