output "user_arn" {
 value = aws_iam_user.ecr_user.arn
}

output "user_access_key" {
 value = aws_iam_access_key.ecr_user_key.id
}

output "user_secret" {
 value = aws_iam_access_key.ecr_user_key.secret
 sensitive = true
}

output "user_secret_encrypted" {
 value = aws_iam_access_key.ecr_user_key.encrypted_secret
 sensitive = true
}

output "ecr_urls" {
 value = aws_ecr_repository.app[*].repository_url
}

output "ecr_arns" {
 value = aws_ecr_repository.app[*].arn
}