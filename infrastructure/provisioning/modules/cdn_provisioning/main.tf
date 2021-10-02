/* Create S3 Buckets */
resource "aws_s3_bucket" "primary" {
  bucket = "${var.cdn.s3_bucket_prefix}-${var.cdn.primary_origin}"
  acl    = "private"

  versioning {
    enabled = true
  }
  
  tags = {
    Name = "${var.cdn.s3_bucket_prefix}-${var.cdn.primary_origin}"
    Environment = var.common_config.environment
  }
}

resource "aws_s3_bucket" "failover" {
  bucket = "${var.cdn.s3_bucket_prefix}-${var.cdn.failover_origin}"
  acl    = "private"
  
  versioning {
    enabled = true
  }
  
  tags = {
    Name = "${var.cdn.s3_bucket_prefix}-${var.cdn.failover_origin}"
    Environment = var.common_config.environment
  }
}

resource "aws_s3_bucket" "cdn_logs" {
  bucket = "${var.cdn.s3_bucket_prefix}-${var.cdn.log_bucket}"
  acl    = "private"

  tags = {
    Name = "${var.cdn.s3_bucket_prefix}-${var.cdn.log_bucket}"
    Environment = var.common_config.environment
  }
}

/* Create user for S3 operation from GitHub actions */

resource "aws_iam_user" "cdn_s3_user" {
  name = var.cdn.cdn_user
  path = "/system/"

  tags = {
    tag-key = "cdn"
    Environment = var.common_config.environment
  }
}

resource "aws_iam_user_policy" "cdn_s3_user_policy" {
  name = "cdn_user_power_policy"
  user = var.cdn.cdn_user

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Sid": "PermissionForS3BucketOperations",
         "Effect": "Allow",
         "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:GetObjectVersion",
            "s3:GetBucketPolicy",
            "s3:GetBucketAcl",
            "s3:GetBucketVersioning",
            "s3:GetLifecycleConfiguration"
         ],
         "Resource": [
            "arn:aws:s3:::${var.cdn.s3_bucket_prefix}-${var.cdn.primary_origin}/*",
            "arn:aws:s3:::${var.cdn.s3_bucket_prefix}-${var.cdn.failover_origin}/*"
         ]
      }
   ]
}
EOF
}

resource "aws_s3_bucket_policy" "bucket_policy_cdn_s3_user_primary" {
  bucket = aws_s3_bucket.primary.id
  depends_on = [aws_s3_bucket.primary]
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Sid": "statement1",
         "Effect": "Allow",
         "Principal": {
            "AWS": "arn:aws:iam::${var.common_config.aws_account_id}:user/system/${var.cdn.cdn_user}"
         },
         "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:GetObjectVersion",
            "s3:GetBucketPolicy",
            "s3:GetBucketAcl",
            "s3:GetBucketVersioning",
            "s3:GetLifecycleConfiguration"
         ],
         "Resource": [
            "arn:aws:s3:::${var.cdn.s3_bucket_prefix}-${var.cdn.primary_origin}",
            "arn:aws:s3:::${var.cdn.s3_bucket_prefix}-${var.cdn.primary_origin}/*"
          ]
      }
   ]
}
EOF
}

resource "aws_s3_bucket_policy" "bucket_policy_cdn_s3_user_failover" {
  bucket = aws_s3_bucket.failover.id
  depends_on = [aws_s3_bucket.failover]
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Sid": "statement1",
         "Effect": "Allow",
         "Principal": {
            "AWS": "arn:aws:iam::${var.common_config.aws_account_id}:user/system/${var.cdn.cdn_user}"
         },
         "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:GetObjectVersion",
            "s3:GetBucketPolicy",
            "s3:GetBucketAcl",
            "s3:GetBucketVersioning",
            "s3:GetLifecycleConfiguration"
         ],
         "Resource": [
            "arn:aws:s3:::${var.cdn.s3_bucket_prefix}-${var.cdn.failover_origin}",
            "arn:aws:s3:::${var.cdn.s3_bucket_prefix}-${var.cdn.failover_origin}/*"
          ]
      }
   ]
}
EOF
}

resource "aws_iam_access_key" "cdn_s3_user" {
  user = aws_iam_user.cdn_s3_user.name
}

/* Create Cloudfront Distribution */
resource "aws_cloudfront_origin_access_identity" "default" {
  comment = var.cdn.origin_access_identity_name
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin_group {
    origin_id = var.cdn.group_origin

    failover_criteria {
      status_codes = var.cdn.failover_status_codes
    }

    member {
      origin_id =  var.cdn.primary_origin
    }

    member {
      origin_id = var.cdn.failover_origin
    }
  }

  origin {
    domain_name = aws_s3_bucket.primary.bucket_regional_domain_name
    origin_id   = var.cdn.primary_origin

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_s3_bucket.failover.bucket_regional_domain_name
    origin_id   = var.cdn.failover_origin

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = var.cdn.cache_behavior.allowed_methods
    cached_methods   = var.cdn.cache_behavior.cached_methods
    target_origin_id = var.cdn.group_origin

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = var.cdn.ttl.min_ttl
    default_ttl            = var.cdn.ttl.default_ttl
    max_ttl                = var.cdn.ttl.max_ttl
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.cdn.description
  default_root_object = var.cdn.default_root_object

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cdn_logs.bucket_regional_domain_name
    prefix          = var.cdn.s3_bucket_prefix
  }

  restrictions {
    geo_restriction {
      restriction_type = var.cdn.restriction.restriction_type
      locations = var.cdn.restriction.locations
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = var.common_config.environment
    Name = var.cdn.name
  }
}

/* Create GitHub secrets */

resource "github_actions_environment_secret" "cdn_access_key" {
  repository       = "3tire_app_fargate"
  environment      = "prod"
  secret_name      = "AWS_CDN_USER_ACCESS_KEY"
  plaintext_value  = aws_iam_access_key.cdn_s3_user.id
}

resource "github_actions_environment_secret" "cdn_secret_key" {
  repository       = "3tire_app_fargate"
  environment      = "prod"
  secret_name      = "AWS_CDN_USER_SECRET_KEY"
  plaintext_value  = aws_iam_access_key.cdn_s3_user.secret
}

resource "github_actions_environment_secret" "cdn_url" {
  repository       = "3tire_app_fargate"
  environment      = "prod"
  secret_name      = "AWS_CDN_DOMAIN"
  plaintext_value  = aws_cloudfront_distribution.s3_distribution.domain_name
}