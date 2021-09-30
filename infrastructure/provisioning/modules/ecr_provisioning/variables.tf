variable "ecr_user" {
  default = "ecr_user"
  description = "IAM Username"
}

variable "apps" {
  type = list(string)
}