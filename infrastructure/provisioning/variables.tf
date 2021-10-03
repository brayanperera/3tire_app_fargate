variable "common_config" {
  type = object({
    aws_account_id = number
    region = string
    failover_region = string
    availability_zones = list(string)
    environment = string
    name_prefix = string
    github_repo = string
    github_repo_env = string
  })
}

variable "ecr" {
  type = object({
    ecr_user = string
  })
}

variable "vpc" {
  type = object({
    vpc_name = string
    vpc_cidr = string
    public_subnets_cidr = list(string)
    private_subnets_cidr = list(string)
  })
}

variable "rds" {
  type = object({
    instance_name = string
    instance_class = string
    allocated_storage = number
    storage_type = string
    engine = string
    engine_version = string
    db_name = string
    db_user = string
    db_pass = string
    backup_retention_period = number
    backup_window = string
    maintenance_window = string
  })
}

variable "apps" {
  type = list(object({
    app_name = string
    port = number
    lb_port = number
    assign_public_ip = bool
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

    autoscaling = object({enable_autoscaling = bool
      max_cpu_threshold = number
      min_cpu_threshold = number
      max_cpu_evaluation_period = string
      min_cpu_evaluation_period = string
      max_cpu_period = number
      min_cpu_period = string
      scale_target_max_capacity = number
      scale_target_min_capacity = number})
  }))
}

variable "fargate" {
  type = object({
    user_policies = list(string)
    iam_user = string
    ecs_cluster = string
    service_log_retention = number
    privileged = bool
    start_timeout = number
    stop_timeout  = number
  })
}

variable "cdn" {
  type = object({
    name = string
    s3_bucket_prefix = string
    group_origin = string
    primary_origin = string
    failover_origin = string
    failover_status_codes = list(number)
    origin_access_identity_name = string
    log_bucket = string
    restriction = object({
      restriction_type = string
      locations = list(string)
    })
    ttl = object({
      min_ttl = number
      default_ttl = number
      max_ttl = number
    })
    description = string
    default_root_object = string
    cache_behavior = object({
      allowed_methods = list(string)
      cached_methods = list(string)
    })
    cdn_user = string
  })
}