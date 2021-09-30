common_config = {
  aws_account_id = "763511508504"
  region = "us-east-1"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  environment = "production"
}

ecr = {
  ecr_user = "ecr_user"
}

vpc = {
  vpc_name = "toptal_vpc"
  vpc_cidr = "10.0.0.0/16"
  public_subnets_cidr = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  private_subnets_cidr = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

rds = {
  cluster_name = "toptal-rds"
  engine_type = "aurora-postgresql"
  db_name = "toptal_api"
  db_user = "api_user"
  db_pass = "Ap1PasS123"
  backup_retention_period = 5
  preferred_backup_window = "01:00-03:00"
}

apps = [
  {
    app_name = "toptal_api"
    port = 5001
    lb_port = 80
    env_vars = [
      {
        name = "PORT"
        value = 5001
      },
      {
        name = "DB"
        value = "toptal_api_db"
      },
      {
        name = "DBUSER"
        value = "api_user"
      },
       {
        name = "DBPASS"
        value = "Ap1PasS123"
      },
      {
        name = "DBHOST"
        value = "localhost"
      },
      {
        name = "DBPORT"
        value = "5432"
      }
    ]
    health_check = {
      path = "/api/status"
      interval = 30
      timeout = 5
      healthy_threshold = 2
      unhealthy_threshold = 2
    }
    module_dir = "./api"
    service_config = {
      cpu = 256
      memory = 1024
      count = 2
    }
    sec_group_rules = [
      {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_block = "0.0.0./0"
        description = "LB access to port 80"
      }
    ]
  },
  {
    app_name = "toptal_web"
    port = 8081
    lb_port = 80
    env_vars = [
      {
        name = "PORT"
        value = 8081
      },
      {
        name = "API_HOST"
        value = ""
      }
    ]
    health_check = {
      path = "/"
      interval = 30
      timeout = 5
      healthy_threshold = 2
      unhealthy_threshold = 2
    }
    module_dir = "./api"
    service_config = {
      cpu = 256
      memory = 1024
      count = 2
    }
    sec_group_rules = [
      {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_block = "0.0.0./0"
        description = "LB access to port 80"
      }
    ]
  }
]

fargate = {
  iam_group = "fargate_execution"
  iam_user = "fargate_user"
  group_policies = ["AmazonECS_FullAccess", "AmazonS3FullAccess"]
}