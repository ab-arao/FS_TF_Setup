terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
    access_key = "${var.aws_root_access_key}"
    secret_key = "${var.aws_root_secret_key}"
    region = "${var.region}"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

// Create a variable for our domain name because we'll be using it a lot.
variable "www_domain_name" {
  default = "www.amiblocked.io"
}

// We'll also need the root domain (also known as zone apex or naked domain).
variable "root_domain_name" {
  default = "amiblocked.io"
}

module "ses-email-forwarding" {
    source = "git@github.com:alemuro/terraform-ses-email-forwarding.git"

    dns_provider     = "aws"
    domain           = "amiblocked.io"
    s3_bucket        = "amiblocked.io.email"
    s3_bucket_prefix = "emails"
    mail_sender      = "postmaster@amiblocked.io"
    mail_recipient   = "fluentstream@dugnet.com"
    aws_region       = "us-west-1"
}
