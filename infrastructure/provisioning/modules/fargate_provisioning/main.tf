resource "aws_security_group" "app_sg" {
  count = length(var.apps)
  name        = var.apps[count.index].app_name
  description = "Security group to allow inbound to ${var.apps[count.index].app_name} LB"
  vpc_id      = var.vpc_id

  tags = {
    Environment = var.common_config.environment
  }

  ingress = var.apps[count.index].sec_group_rules
}

module "ecs-fargate" {
  count = length(var.apps)
  source  = "cn-terraform/ecs-fargate/aws"
  version = "2.0.26"

  container_image = "${var.common_config.aws_account_id}.dkr.ecr.${var.common_config.region}.amazonaws.com/${var.apps[count.index].app_name}:latest"
  container_name = var.apps[count.index].app_name
  name_prefix = var.apps[count.index].app_name
  private_subnets_ids = var.private_subnets_ids
  public_subnets_ids = var.public_subnets_ids
  vpc_id = var.vpc_id
  firelens_configuration = var.fargate.firelens_configuration
  log_configuration = var.fargate.log_configuration
  privileged = var.fargate.privileged
  start_timeout = var.fargate.start_timeout
  stop_timeout = var.fargate.stop_timeout
  working_directory = var.apps[count.index].working_directory
  container_cpu = var.apps[count.index].service_config.cpu
  container_memory = var.apps[count.index].service_config.memory
  desired_count = var.apps[count.index].service_config.count
  environment  = var.apps[count.index].env_vars
  lb_security_groups = concat(aws_security_group.app_sg[*].id, [var.default_security_group])
  lb_target_group_health_check_healthy_threshold  = var.apps[count.index].health_check.healthy_threshold
  lb_target_group_health_check_unhealthy_threshold = var.apps[count.index].health_check.unhealthy_threshold
  lb_target_group_health_check_interval = var.apps[count.index].health_check.interval
  lb_target_group_health_check_path  = var.apps[count.index].health_check.path
  lb_target_group_health_check_timeout  = var.apps[count.index].health_check.timeout
  port_mappings = var.apps[count.index].port_mapping
  lb_http_ports = var.apps[count.index].lb_http_port_map
  lb_https_ports = {}
  container_memory_reservation = 512
}