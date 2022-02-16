terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.74.2"
    }
  }
}

provider "aws" {
    access_key = "${var.aws_root_access_key}"
    secret_key = "${var.aws_root_secret_key}"
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

module "aurora-serverless" {
  source  = "git@github.com:superdug/terraform-aws-aurora-serverless.git"
  # insert the 4 required variables here

  engine = "aurora-postgresql"
  engine_version = "10.14"
  vpc_config = {
    azs              = slice(data.aws_availability_zones.current.names, 0, 3)
    cidr_block       = "10.0.0.0/16"
    database_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  }
  name = "amiblocked-api-db-pgsql"
  scaling_configuration = {
    auto_pause               = false
    max_capacity             = 16
    min_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }
}

data "aws_availability_zones" "current" {
  state = "available"
}
