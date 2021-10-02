output "user_arn" {
 value = aws_iam_user.cdn_s3_user.arn
}

output "user_access_key" {
 value = aws_iam_access_key.cdn_s3_user.id
}

output "user_secret" {
 value = aws_iam_access_key.cdn_s3_user.secret
 sensitive = true
}

output "cdn_url" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}