variable "ecr_user" {
  default = "ecr_user"
  description = "IAM Username"
}

variable "apps" {
  type = list(string)
}

variable "github_repo" {}

variable "github_repo_env" {}

variable "common_config" {
  type = object({
    aws_account_id = number
    region = string
    failover_region = string
    availability_zones = list(string)
    environment = string
    name_prefix = string
  })
}