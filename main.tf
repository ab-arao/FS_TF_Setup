provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

module "s3" {
    source = "./S3"
    #bucket name should be unique
    amiblocked_bucket_name = "amiblocked"   
}