/* IAM Users and Policies for Fargate */
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
})
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole-attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_user" "fargate_user" {
  name = var.fargate.iam_user
  path = "/system/"

  tags = {
    tag-key = "fargate"
    Environment = var.common_config.environment
  }
}

resource "aws_iam_user_policy_attachment" "fargate_user_policy_attach" {
  count = length(var.fargate.user_policies)
  user       = aws_iam_user.fargate_user.name
  policy_arn = "arn:aws:iam::aws:policy/${var.fargate.user_policies[count.index]}"
}

resource "aws_iam_access_key" "fargate_user" {
  user = aws_iam_user.fargate_user.name
}


/* ECS Cluster */
module "ecs-cluster" {
  source  = "cn-terraform/ecs-cluster/aws"
  version = "1.0.7"

  name = var.fargate.ecs_cluster
  tags = {
    Name        = var.fargate.ecs_cluster
    Environment = var.common_config.environment
  }
}

/* GitHub Secret Create */
resource "github_actions_environment_secret" "fargate_access_key" {
  repository       = var.common_config.github_repo
  environment      = var.common_config.github_repo_env
  secret_name      = "AWS_FARGATE_USER_ACCESS_KEY"
  plaintext_value  = aws_iam_access_key.fargate_user.id
}

resource "github_actions_environment_secret" "fargate_secret_key" {
  repository       = var.common_config.github_repo
  environment      = var.common_config.github_repo_env
  secret_name      = "AWS_FARGATE_USER_SECRET_KEY"
  plaintext_value  = aws_iam_access_key.fargate_user.secret
}
