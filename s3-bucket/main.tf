# Variables
variable "app_region" {}

variable "account_id" {}

variable "app_name" {}

variable "root_domain_name" {}

variable "bucket_name" {}


resource "aws_s3_bucket" "artefacts_bucket" {
  // bucket name with account id prefix
  bucket = "${var.account_id}-${var.root_domain_name}-${var.bucket_name}"

  // Because we want our site to be available on the internet, we set this so
  // anyone can read this bucket.
  # acl = "public-read"

  // We also need to create a policy that allows anyone to view the content.
  // This is basically duplicating what we did in the ACL but it's required by
  // AWS. This post: http://amzn.to/2Fa04ul explains why.
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":[
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource":["arn:aws:s3:::${var.account_id}-${var.root_domain_name}-${var.bucket_name}/*"]
    }
  ]
}
POLICY
}

output "bucket_arn" {
  value = "${aws_s3_bucket.artefacts_bucket.arn}"
}

output "bucket_id" {
  value = "${aws_s3_bucket.artefacts_bucket.id}"
}
