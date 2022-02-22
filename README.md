# Welcome to amiblocked.io terraform repository

## Email Forward Setup

This repository sets up an autoforward to send email addressed to a list of defined addresses to a single specified external email address using AWS Lambda and S3 entirely

The email module is stored here ( https://github.com/superdug/terraform-aws-ses-email-forwarding ) and is invoked in `main.tf` under the following definion

```
module "ses-email-forwarding" {
   source = "git@github.com:superdug/terraform-aws-ses-email-forwarding.git"

    dns_provider     = "aws"
    domain           = "amiblocked.io"
    s3_bucket        = "amiblocked.io.emails"
    s3_bucket_prefix = "emails"
    mail_targets     = ["test@amiblocked.io", "administrator@amiblocked.io", "hostmaster@amiblocked.io", "postmaster@amiblocked.io", "webmaster@amiblocked.io", "admin@amiblocked.io"]
    mail_sender      = "postmaster@amiblocked.io"
    mail_recipient   = "hello@aleix.cloud"
}
```
**NOTE**

An email will be sent to the `mail_recepient` address from AWS to you for verifying that you can receive emails at that address before proceeding


## ACM, S3, Cloud Front CDN Setup

The next step is to create a static website that hosts our frontend located in `/website` and uploaded files include `/website/index.html` and `/website/error.html`

The three main variables set in `variables.tf` are as follows:

* `region` - sets the active AWS region
* `root_domain_name` - sets the domain name root address

Once those variables are set an S3 bucket to serve static websites out will be created.  The traffic will be encrypted using ACM https certificates and a cloudfront CDN will be created to serve the hosted webpage.

## Serverless SQL Setup DEFUNCT

Now we need a database and want it to be serverless as well, so lets make a postgresql database on top of Amazon Auror ServerLess 

The database module is stored here ( https://github.com/superdug/terraform-aws-aurora-serverless ) snd is invoked in the `main.cf` under the following definition

```
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
```

