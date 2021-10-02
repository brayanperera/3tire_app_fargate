variable "common_config" {
  type = object({
    aws_account_id = number
    region = string
    failover_region = string
    availability_zones = list(string)
    environment = string
    name_prefix = string
  })
}

variable "cdn" {
  type = object({
    name = string
    s3_bucket_prefix = string
    group_origin = string
    primary_origin = string
    failover_origin = string
    failover_status_codes = list(number)
    origin_access_identity_name = string
    log_bucket = string
    restriction = object({
      restriction_type = string
      locations = list(string)
    })
    ttl = object({
      min_ttl = number
      default_ttl = number
      max_ttl = number
    })
    description = string
    default_root_object = string
    cache_behavior = object({
      allowed_methods = list(string)
      cached_methods = list(string)
    })
    cdn_user = string
  })
}