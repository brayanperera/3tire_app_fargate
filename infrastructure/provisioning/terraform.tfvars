common_config = {
  aws_account_id = "763511508504"
  region = "us-east-1"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  environment = "prod"
  name_prefix = "toptal"
}

ecr = {
  ecr_user = "ecr_user"
  github_repo = "brayanperera/3tire_app_fargate"
  github_repo_env = "prod"
}

vpc = {
  vpc_name = "toptal_vpc"
  vpc_cidr = "10.0.0.0/16"
  public_subnets_cidr = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  private_subnets_cidr = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

rds = {
  instance_name = "toptal-rds-db"
  instance_class = "db.t3.micro"
  allocated_storage = 5
  storage_type = "gp2"
  engine = "postgres"
  engine_version = "13.3"
  db_name = "toptal_api"
  db_user = "api_user"
  db_pass = "Ap1PasS123"
  backup_retention_period = 5
  backup_window = "01:00-03:00"
  maintenance_window = "mon:04:00-mon:06:00"
}

apps = [
  {
    app_name = "toptal-api"
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
        name = "DBPORT"
        value = "5432"
      }
    ]
    health_check = {
      path = "/status"
      interval = 30
      timeout = 5
      healthy_threshold = 2
      unhealthy_threshold = 2
    }
    module_dir = "./api"
    working_directory = "/usr/src/app"
    service_config = {
      cpu = 256
      memory = 512
      count = 2
    }
    sec_group_rules = [
      {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        prefix_list_ids = []
        security_groups = []
        self = false
        description = "LB access to port 80"
      }
    ]
  },
  {
    app_name = "toptal-web"
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
      path = "/status"
      interval = 30
      timeout = 5
      healthy_threshold = 2
      unhealthy_threshold = 2
    }
    module_dir = "./api"
    working_directory = "/usr/src/app"
    service_config = {
      cpu = 256
      memory = 512
      count = 2
    }
    sec_group_rules = [
      {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        prefix_list_ids = []
        security_groups = []
        self = false
        description = "LB access to port 80"
      }
    ]
  }
]

fargate = {
  iam_group = "fargate_execution"
  iam_user = "fargate_user"
  group_policies = ["AmazonECS_FullAccess", "AmazonS3FullAccess"]
  ecs_cluster = "toptal-ecs"
  service_log_retention = 15
  privileged = false
  start_timeout = 60
  stop_timeout = 60
}