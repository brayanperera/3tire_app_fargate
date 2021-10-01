variable "db_availability_zones" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "subnets" {
  type = list(string)
  description = "VPC Subnets"
}

variable "security_groups" {
  type = list(string)
  description = "VPC Security groups"
}

variable "rds" {
  type = object({
      instance_name = string
      instance_class = string
      engine = string
      engine_version = string
      db_name = string
      db_user = string
      db_pass = string
      backup_retention_period = number
      preferred_backup_window = string
  })
}