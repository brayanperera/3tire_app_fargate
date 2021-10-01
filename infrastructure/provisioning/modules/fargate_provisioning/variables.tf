variable "vpc_id" {}

variable "public_subnets_ids" {
  type = list(string)
}

variable "private_subnets_ids" {
  type = list(string)
}

variable "default_security_group" {}

variable "rds_db_endpoint" {}

variable "aws_ecs_cluster_arn" {}

variable "fargate" {
  type = object({
    iam_group = string
    group_policies = list(string)
    iam_user = string
    ecs_cluster = string
    service_log_retention = number
    privileged = bool
    start_timeout = number
    stop_timeout  = number
  })
}

variable "common_config" {
  type = object({
    aws_account_id = number
    region = string
    availability_zones = list(string)
    environment = string
  })
}

variable "app" {
    app_name = string
    port = number
    lb_port = number
    env_vars = list(object({
      name = string
      value = string
    }))
    health_check = object({
      path = string
      interval = number
      timeout = number
      healthy_threshold = number
      unhealthy_threshold = number
    })
    module_dir = string
    working_directory = string
    service_config = object({
      cpu = number
      memory = number
      count = number
      memory_reservation = number
    })
    sec_group_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks  = list(string)
      ipv6_cidr_blocks = list(string)
      prefix_list_ids = list(string)
      security_groups = list(string)
      self = bool
      description = string
    }))
}