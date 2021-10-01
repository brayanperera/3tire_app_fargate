/* Cloudwatch logs */
resource "aws_cloudwatch_log_group" "toptal_logs" {
  name = "${var.app.app_name}-logs"
  retention_in_days = var.fargate.service_log_retention

  tags = {
    Environment = var.common_config.environment
    Name = "${var.app.app_name}-logs"
  }
}

/* Task Def */

locals {
  db_host_env = {
    name = "DBHOST"
    value = var.rds_db_endpoint
  }
}

module "task_def" {
  source  = "cn-terraform/ecs-fargate-task-definition/aws"
  version = "1.0.23"

  container_image = "${var.common_config.aws_account_id}.dkr.ecr.${var.common_config.region}.amazonaws.com/${var.app.app_name}:latest"
  container_name  = var.app.app_name
  name_prefix     = var.fargate.ecs_cluster
  container_memory = var.app.service_config.memory
  container_memory_reservation = var.app.service_config.memory_reservation
  port_mappings = {
    containerPort = var.app.port
    hostPort = var.app.port
    protocol = "tcp"
  }
  container_cpu = var.app.service_config.cpu
  working_directory = var.app.working_directory
  environment  = concat(var.app.env_vars, var.app.app_name == "toptal-api" ? [local.db_host_env]: [])
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group = "${var.app.app_name}-logs"
      awslogs-region = var.common_config.region
      awslogs-stream-prefix = var.app.app_name
    }
  }
  privileged = var.fargate.privileged
  start_timeout = var.fargate.start_timeout
  stop_timeout = var.fargate.stop_timeout
}

module "ecs-fargate-service" {
  source  = "cn-terraform/ecs-fargate-service/aws"
  version = "2.0.15"

  container_name      = var.app.app_name
  ecs_cluster_arn     = var.aws_ecs_cluster_arn
  name_prefix         = var.fargate.ecs_cluster
  private_subnets     = var.private_subnets_ids
  public_subnets      = var.public_subnets_ids
  task_definition_arn = module.task_def.aws_ecs_task_definition_td_arn
  vpc_id              = var.vpc_id
}