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


module "lb_provisioning" {
  source = "./modules/lb_provisioning"
  common_config = var.common_config
  vpc = var.vpc
  apps = var.apps
  vpc_id = module.vpc_provisioning.vpc_id
  default_sec_group_id = module.vpc_provisioning.default_sec_group_id
  subnet_ids = module.vpc_provisioning.vpc_public_subnet_ids
}

module "ecs_provisioning" {
  source = "./modules/ecs_provisioning"
  common_config = var.common_config
  fargate = var.fargate
}

#module "fargate_provisioning" {
#  source = "./modules/fargate_provisioning"
#
#  count = length(var.apps)
#  vpc_id = module.vpc_provisioning.vpc_id
#  public_subnets_ids = module.vpc_provisioning.vpc_public_subnet_ids
#  private_subnets_ids = module.vpc_provisioning.vpc_private_subnet_ids
#  default_security_group = module.vpc_provisioning.default_sec_group_id
#  common_config = var.common_config
#  aws_ecs_cluster_arn = module.ecs_provisioning.aws_ecs_cluster_cluster_arn
#  rds_db_endpoint = module.db_provisioning.rds_endpoint
#  fargate = var.fargate
#  app = var.apps[count.index]
#}

