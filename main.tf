provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

// Create a variable for our domain name because we'll be using it a lot.
variable "www_domain_name" {
  default = "www.amiblocked.io"
}

// We'll also need the root domain (also known as zone apex or naked domain).
variable "root_domain_name" {
  default = "amiblocked.io"
}

module "ses-email-forwarding" {
    source = "git@github.com:superdug/terraform-aws-ses-email-forwarding.git"

    dns_provider     = "aws"
    domain           = "amiblocked.io"
    s3_bucket        = "amiblocked.io.emails"
    s3_bucket_prefix = "emails"
    mail_targets     = ["test@amiblocked.io", "administrator@amiblocked.io", "hostmaster@amiblocked.io", "postmaster@amiblocked.io", "webmaster@amiblocked.io", "admin@amiblocked.io"]
    mail_sender      = "postmaster@amiblocked.io"
    mail_recipient   = "fluentsteam@dugnet.com"
    aws_region       = "${var.region}"
}
