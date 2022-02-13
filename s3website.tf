resource "aws_s3_bucket" "www" {
  bucket = "${var.root_domain_name}"
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.www.bucket
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.www.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "index" {
 bucket = aws_s3_bucket.www.bucket

  key = "index.html"

  acl = "public-read"
  source = "${path.module}/website/index.html" 

  content_type = "text/html"
} 

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.www.bucket

  key = "error.html"

  acl = "public-read"
  source = "${path.module}/website/error.html"

  content_type = "text/html"
}