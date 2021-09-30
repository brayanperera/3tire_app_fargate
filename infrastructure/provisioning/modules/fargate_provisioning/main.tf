/*==== Fargate: IAM config  ======*/
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "1_assume_policy",
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

resource "aws_iam_group" "fargate_execution" {
  name = var.fargate.iam_group
  path = "/users/"
}

resource "aws_iam_group_policy_attachment" "fargate_execution-ecs-attach" {
  group      = aws_iam_group.fargate_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_group_policy_attachment" "fargate_execution_policy_attach" {
  count = length(var.fargate.group_policies)
  group      = aws_iam_group.fargate_execution.name
  policy_arn = "arn:aws:iam::aws:policy/${var.fargate.group_policies[count.index]}"
}

/*==== Fargate: ECS Cluster  ======*/

module "ecs-cluster" {
  source  = "cn-terraform/ecs-cluster/aws"
  version = "1.0.7"
  name = var.fargate.ecs_cluster
}

module "ecs-fargate" {
  count = length(var.apps)
  source  = "cn-terraform/ecs-fargate/aws"
  version = "2.0.26"
  # insert the 25 required variables here
  container_image = "${var.common_config.aws_account_id}.dkr.ecr.${var.common_config.region}.amazonaws.com/${var.apps[count.index].app_name}:latest"
  container_name = var.apps[count.index].app_name
  name_prefix = ""
  private_subnets_ids = []
  public_subnets_ids = []
  vpc_id = ""
}