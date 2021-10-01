variable "common_config" {
  type = object({
    aws_account_id = number
    region = string
    availability_zones = list(string)
    environment = string
    name_prefix = string
  })
}

variable "ecr" {
  type = object({
    ecr_user = string
    github_repo = string
    github_repo_env = string
  })
}

variable "github_token" {}

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
    port_mapping = list(object({
      containerPort = number
      hostPort = number
      protocol = string
    }))

    lb_http_port_map = object({
      default_http = object({
        listener_port =  number
        target_group_port = number
      })
    })
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
  }))
}

variable "fargate" {
  type = object({
    iam_group = string
    group_policies = list(string)
    iam_user = string
    ecs_cluster = string
    firelens_configuration = object({
      type = string
      options = map(string)
    })
    log_configuration = object({
      logDriver = string
      options = map(string)
    })
    privileged = bool
    start_timeout = number
    stop_timeout  = number
  })
}