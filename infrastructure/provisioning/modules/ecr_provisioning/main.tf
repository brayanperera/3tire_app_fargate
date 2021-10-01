resource "aws_iam_user" "ecr_user" {
  name = var.ecr_user
  path = "/system/"

  tags = {
    tag-key = "ecr"
    Environment = var.common_config.environment
  }
}

resource "aws_iam_access_key" "ecr_user" {
  user = aws_iam_user.ecr_user.name
}

resource "aws_iam_user_policy" "ecr_user_ro" {
  name = "ecr_user_power_policy"
  user = aws_iam_user.ecr_user.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:GetLifecyclePolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:ListTagsForResource",
                "ecr:DescribeImageScanFindings",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_access_key" "ecr_user_key" {
  user = aws_iam_user.ecr_user.name
}

resource "aws_ecr_repository" "app" {
  count = length(var.apps)
  name = var.apps[count.index]

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "github_actions_environment_secret" "ecr_access_key" {
  repository       = "3tire_app_fargate"
  environment      = "prod"
  secret_name      = "AWS_ECR_USER_ACCESS_KEY"
  plaintext_value  = aws_iam_access_key.ecr_user_key.id
}

resource "github_actions_environment_secret" "ecr_secret_key" {
  repository       = "3tire_app_fargate"
  environment      = "prod"
  secret_name      = "AWS_ECR_USER_SECRET_KEY"
  plaintext_value  = aws_iam_access_key.ecr_user_key.secret
}