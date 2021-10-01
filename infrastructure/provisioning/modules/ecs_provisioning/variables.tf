variable "common_config" {
  type = object({
    aws_account_id = number
    region = string
    availability_zones = list(string)
    environment = string
  })
}

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