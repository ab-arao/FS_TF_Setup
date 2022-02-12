variable "amiblocked_bucket_name" {}

variable "amiblocked_acl_value" {
    default = "public-read"
}

variable "amiblocked_logging_acl_value" {
    default = "private"
}