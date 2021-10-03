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