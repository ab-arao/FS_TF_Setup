terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.74.2"
    }
  }
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = var.region
}

module "ses-email-forwarding" {
    source = "git@github.com:superdug/terraform-aws-ses-email-forwarding.git"

    dns_provider     = "aws"
    domain           = "amiblocked.io"
    s3_bucket        = "amiblocked.io.emails"
    s3_bucket_prefix = "emails"
    mail_targets     = ["test@amiblocked.io", "administrator@amiblocked.io", "hostmaster@amiblocked.io", "postmaster@amiblocked.io", "webmaster@amiblocked.io", "admin@amiblocked.io"]
    mail_sender      = "postmaster@amiblocked.io"
    mail_recipient   = "fs@dugnet.com"
    aws_region       = "${var.region}"
}
