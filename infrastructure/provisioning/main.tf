module "ecr_provisioning" {
  source = "./modules/ecr_provisioning"
  ecr_user = var.ecr.ecr_user
  apps = var.apps[*].app_name
  github_repo = var.ecr.github_repo
  github_repo_env = var.ecr.github_repo_env
  common_config = var.common_config
}

module "vpc_provisioning" {
  source = "./modules/vpc_provisioning"
  common_config = var.common_config
  vpc = var.vpc
}

module "db_provisioning" {
  source = "./modules/db_provisioning"
  security_groups = module.vpc_provisioning.security_groups
  subnets         = module.vpc_provisioning.vpc_private_subnet_ids
  db_availability_zones = var.common_config.availability_zones
  rds = var.rds
  common_config = var.common_config
}

module "ecs_provisioning" {
  source = "./modules/ecs_provisioning"
  common_config = var.common_config
  fargate = var.fargate
}

module "cdn_provisioning" {
  source = "./modules/cdn_provisioning"
  cdn    = var.cdn
  common_config = var.common_config
}

#module "fargate_provisioning" {
#  source = "./modules/fargate_provisioning"
#
#  count = length(var.apps)
#  app                    = var.apps[count.index]
#  aws_ecs_cluster_arn    = module.ecs_provisioning.aws_ecs_cluster_cluster_arn
#  common_config          = var.common_config
#  default_security_group = module.vpc_provisioning.default_sec_group_id
#  fargate                = var.fargate
#  lb_subnet_ids          = module.vpc_provisioning.vpc_public_subnet_ids
#  private_subnets_ids    = module.vpc_provisioning.vpc_private_subnet_ids
#  public_subnets_ids     = module.vpc_provisioning.vpc_public_subnet_ids
#  rds_db_endpoint        = module.db_provisioning.rds_endpoint
#  task_role_arn          = module.ecs_provisioning.task_role_arn
#  vpc_id                 = module.vpc_provisioning.vpc_id
#}
