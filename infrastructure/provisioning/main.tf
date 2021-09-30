terraform {
  backend "s3" {
    bucket         = "toptal-tire3-app-brayan-tf-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "toptal_3tire_app_infra_locks"
    encrypt        = true
  }
}

module "ecr_provisioning" {
  source = "./modules/ecr_provisioning"
  ecr_user = var.ecr.ecr_user
  apps = var.apps[*].app_name
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
}

#
#module "lb_provisioning" {
#  source = "./modules/lb_provisioning"
#  common_config = var.common_config
#  vpc = var.vpc
#  apps = var.apps
#  vpc_id = module.vpc_provisioning.vpc_id
#  default_sec_group_id = module.vpc_provisioning.default_sec_group_id
#  subnet_ids = concat(module.vpc_provisioning.vpc_private_subnet_ids, module.vpc_provisioning.vpc_public_subnet_ids )
#}