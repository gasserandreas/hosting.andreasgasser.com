variable "app_region" {}

variable "account_id" {}

variable "app_name" {}

variable "role_name" {}

resource "aws_iam_role" "codebuild" {
  name = "${var.app_name}-codebuild-${var.role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

output "role_arn" {
  value = "${aws_iam_role.codebuild.arn}"
}

output "role_name" {
  value = "${aws_iam_role.codebuild.name}"
}
