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
  instance_class = "db.t3.micro"
  engine = "postgresql"
  db_name = "toptal_api"
  db_user = "api_user"
  db_pass = "Ap1PasS123"
  backup_retention_period = 5
  preferred_backup_window = "01:00-03:00"
}

apps = [
  {
    app_name = "toptal-api"
    port_mapping = [
      {
        containerPort = 5001
        hostPort = 5001
        protocol = "tcp"
      }
    ]
    lb_http_port_map = {
      default_http = {
        listener_port = 80
        target_group_port = 5001
      }
    }
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
    port_mapping = [
      {
        containerPort = 8081
        hostPort = 8081
        protocol = "tcp"
      }
    ]
    lb_http_port_map = {
      default_http = {
        listener_port = 80
        target_group_port = 8081
      }
    }
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
  firelens_configuration = {
    type = "fluentbit"
    options = {}
  }
  log_configuration = {
    logDriver = "awsfirelens"
    options = {}
  }
  privileged = false
  start_timeout = 60
  stop_timeout = 60
}