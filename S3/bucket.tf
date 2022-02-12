resource "aws_s3_bucket" "amiblocked" {
    bucket = "${var.amiblocked_bucket_name}"
}

resource "aws_s3_bucket" "amiblocked-logging" {
    bucket = "${var.amiblocked_bucket_name}-logging"
}

resource "aws_s3_bucket_website_configuration" "amiblocked" {
    bucket = "${var.amiblocked_bucket_name}" 

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket_acl" "amiblocked-logging" {
  bucket = aws_s3_bucket.amiblocked-logging.id
    access_control_policy {
      grant {
        grantee {
          id   = data.aws_canonical_user_id.current.id
          type = "CanonicalUser"
        }
        permission = "READ"
      }

      grant {
        grantee {
          type = "Group"
          uri  = "http://acs.amazonaws.com/groups/s3/LogDelivery"
        }
        permission = "READ_ACP"
      }

      owner {
        id = data.aws_canonical_user_id.current.id
      }
    }
  }

resource "aws_s3_bucket_acl" "amiblocked" {
  bucket = aws_s3_bucket.amiblocked.id
  acl    = "${var.amiblocked_acl_value}"
}

resource "aws_s3_bucket_logging" "amiblocked" {
  bucket = aws_s3_bucket.amiblocked.id

  target_bucket = aws_s3_bucket.amiblocked-logging.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_public_access_block" "amiblocked" {
  bucket = aws_s3_bucket.amiblocked.id

  block_public_acls   = false
  block_public_policy = false
}