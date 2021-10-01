output "ecr_repo_urls" {
  value = module.ecr_provisioning.ecr_urls
}

output "ecr_user_access_key" {
  value = module.ecr_provisioning.user_access_key
}

output "ecr_user_secret_key" {
  value = module.ecr_provisioning.user_secret
  sensitive = true
}

output "vpc_id" {
  value = module.vpc_provisioning.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc_provisioning.vpc_public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc_provisioning.vpc_private_subnet_ids
}

#output "rds_endpoint" {
#  value = module.db_provisioning.rds_endpoint
#}
#
#output "rds_read_endpoint" {
#  value = module.db_provisioning.rds_read_endpoint
#}