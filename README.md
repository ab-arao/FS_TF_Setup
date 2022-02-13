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

The next step is to create a static website that hosts our frontend located in `/webpage` and uploaded files include '/webpage/index.html` and `/webpage/error.html`

The three main variables set in `variables.tf` are as follows:

* `region` - sets the active AWS region
* `root_domain_name` - sets the domain name root address

Once those variables are set an S3 bucket to serve static websites out will be created.  The traffic will be encrypted using ACM https certificates and a cloudfront CDN will be created to serve the hosted webpage.