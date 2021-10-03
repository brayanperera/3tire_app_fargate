variable "common_config" {
  type = object({
    aws_account_id = number
    region = string
    availability_zones = list(string)
    environment = string
    name_prefix = string
    github_repo = string
    github_repo_env = string
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