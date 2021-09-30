variable "vpc_id" {}
variable "default_sec_group_id" {}
variable "subnet_ids" {}

variable "common_config" {
  type = object({
    aws_account_id = number
    region = string
    availability_zones = list(string)
    environment = string
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

variable "apps" {
  type = list(object({
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
    service_config = object({
      cpu = number
      memory = number
      count = number
    })
    sec_group_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_block  = string
      description = string
    }))
  }))
}