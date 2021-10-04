#/* ECR Outputs */
#output "ecr_repo_urls" {
#  value = module.ecr_provisioning.ecr_urls
#}
#
#output "ecr_user_access_key" {
#  value = module.ecr_provisioning.user_access_key
#}
#
#output "ecr_user_secret_key" {
#  value = module.ecr_provisioning.user_secret
#  sensitive = true
#}
#
#/* VPC Outputs */
#output "vpc_id" {
#  value = module.vpc_provisioning.vpc_id
#}
#
#output "public_subnet_ids" {
#  value = module.vpc_provisioning.vpc_public_subnet_ids
#}
#
#output "private_subnet_ids" {
#  value = module.vpc_provisioning.vpc_private_subnet_ids
#}
#
#/* RDS Outputs */
#output "rds_endpoint" {
#  value = module.db_provisioning.rds_endpoint
#}
#
#/* ECS Outputs */
#output "ecs_cluster_id" {
#  value = module.ecs_provisioning.aws_ecs_cluster_cluster_id
#}
#
#/* CDN Outputs */
#output "cdn_user_arn" {
# value = module.cdn_provisioning.user_arn
#}
#
#output "cdn_user_access_key" {
# value = module.cdn_provisioning.user_access_key
#}
#
#output "cdn_user_secret" {
# value = module.cdn_provisioning.user_secret
# sensitive = true
#}
#
#output "cdn_url" {
#  value = module.cdn_provisioning.cdn_url
#}
#
#/* Fargate Outputs */