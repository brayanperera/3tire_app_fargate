/* Provision IAM User for GitHub Actions */


/* Provision ALB */
module "lb_provisioning" {
  source = "../lb_provisioning"
  common_config = var.common_config
  app = var.app
  vpc_id = var.vpc_id
  default_sec_group_id = var.default_security_group
  subnet_ids = var.lb_subnet_ids
}

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

  cdn_url_env = {
    name = "CDN_URL"
    value = var.cdn_url
  }
}

module "container_def" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.53.0"

  container_image = "${var.common_config.aws_account_id}.dkr.ecr.${var.common_config.region}.amazonaws.com/${var.app.app_name}:latest"
  container_name  = var.app.app_name
  container_memory = var.app.service_config.memory
  container_memory_reservation = var.app.service_config.memory_reservation
  port_mappings = [{
    containerPort = var.app.port
    hostPort = var.app.port
    protocol = "tcp"
  }]
  container_cpu = var.app.service_config.cpu
  working_directory = var.app.working_directory
  environment  = concat(var.app.env_vars, var.app.app_name == "toptal-api" ? [local.db_host_env]: [], var.app.app_name == "toptal-web" ? [local.cdn_url_env]: [])
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

# Task Definition
resource "aws_ecs_task_definition" "td" {
  family                = "${var.app.app_name}-td"
  container_definitions = "[${module.container_def.json_map_encoded}]"
  task_role_arn         = var.task_role_arn
  execution_role_arn    = var.task_role_arn
  network_mode          = "awsvpc"
  cpu                      = var.app.service_config.cpu
  memory                   = var.app.service_config.memory
  requires_compatibilities = ["FARGATE"]

  tags = {
    Environment = var.common_config.environment
    Name = "${var.app.app_name}-td"
  }
}


resource "aws_ecs_service" "app_service" {
  name            = "${var.app.app_name}-service"
  cluster         = var.aws_ecs_cluster_arn
  task_definition = aws_ecs_task_definition.td.arn
  desired_count   = var.app.service_config.count
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = module.lb_provisioning.app_tg_arn
    container_name   = var.app.app_name
    container_port   = var.app.port
  }

  network_configuration {
    security_groups  = [var.default_security_group]
    subnets          = var.app.assign_public_ip ? var.private_subnets_ids : var.private_subnets_ids
    assign_public_ip = var.app.assign_public_ip
  }
}

module "ecs-autoscaling" {
  count = var.app.autoscaling.enable_autoscaling ? 1 : 0

  source  = "cn-terraform/ecs-service-autoscaling/aws"
  version = "1.0.3"

  name_prefix               = var.fargate.ecs_cluster
  ecs_cluster_name          = var.fargate.ecs_cluster
  ecs_service_name          = aws_ecs_service.app_service.name
  max_cpu_threshold         = var.app.autoscaling.max_cpu_threshold
  min_cpu_threshold         = var.app.autoscaling.min_cpu_threshold
  max_cpu_evaluation_period = var.app.autoscaling.max_cpu_evaluation_period
  min_cpu_evaluation_period = var.app.autoscaling.min_cpu_evaluation_period
  max_cpu_period            = var.app.autoscaling.max_cpu_period
  min_cpu_period            = var.app.autoscaling.min_cpu_period
  scale_target_max_capacity = var.app.autoscaling.scale_target_max_capacity
  scale_target_min_capacity = var.app.autoscaling.scale_target_min_capacity
  tags                      = {
    Name        = var.fargate.ecs_cluster
    Environment = var.common_config.environment
  }
}
