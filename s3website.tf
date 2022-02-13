resource "aws_s3_bucket" "b" {
  bucket = "${var.root_domain_name}"
  acl    = "public-read"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[{
        "Sid":"PublicReadForGetBucketObjects",
        "Effect":"Allow",
          "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.root_domain_name}/*"]
    }
  ]
}
EOF

  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
/*
resource "aws_s3_bucket_object" "object1" {
  for_each = fileset("website/", "*")
  bucket = aws_s3_bucket.b.id
  key = each.value
  source = "website/${each.value}"
  etag = filemd5("website/${each.value}")
  content_type = "text/html"
}
*/

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.b.id

  key = "index.html"

  acl = "public-read"
  source = "${path.module}/website/index.html" 

  content_type = "text/html"

  force_destroy = true
} 

resource "aws_s3_bucket_object" "error" {
  bucket = aws_s3_bucket.b.id

  key = "error.html"

  acl = "public-read"
  source = "${path.module}/website/error.html"

  content_type = "text/html"

  force_destroy = true
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.root_domain_name}"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "zone" {
  name         = "${var.root_domain_name}"
  private_zone = false
}

// Route 53 Record
 resource "aws_route53_record" "www" {
   for_each = {
     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
       name   = dvo.resource_record_name
       record = dvo.resource_record_value
       type   = dvo.resource_record_type
     }
   }

   allow_overwrite = true
   name            = each.value.name
   records         = [each.value.record]
   ttl             = 60
   type            = each.value.type
   zone_id         = data.aws_route53_zone.zone.zone_id
 }

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = [for record in aws_route53_record.www : record.fqdn]
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.b.bucket_regional_domain_name
    origin_id   = "${var.root_domain_name}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

   custom_error_response {
      error_caching_min_ttl = 3000
      error_code = 404
      response_code = 200
      response_page_path = "/error.html"
  }


  logging_config {
    include_cookies = false
    bucket          = "${var.root_domain_name}.s3.amazonaws.com"
    prefix          = "cloudfront_logs"
  }

  aliases = ["${var.root_domain_name}"]

  default_cache_behavior {
     allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
     cached_methods   = ["GET", "HEAD"]
     target_origin_id = "${var.root_domain_name}"
  

    forwarded_values {
        query_string = false
        cookies {
          forward = "none"
        }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "allow-all"
  }

  ordered_cache_behavior {
     path_pattern     = "/*"
     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
     cached_methods   = ["GET", "HEAD", "OPTIONS"]
     target_origin_id = "${var.root_domain_name}"

     forwarded_values {
       query_string = false
       headers      = ["Origin"]

       cookies {
         forward = "none"
       }
     }

     min_ttl                = 0
     default_ttl            = 86400
     max_ttl                = 31536000
     compress               = true
     viewer_protocol_policy = "redirect-to-https"
   }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method = "sni-only"
  }
}