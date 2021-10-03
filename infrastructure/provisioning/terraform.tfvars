common_config = {
  aws_account_id = "763511508504"
  region = "us-east-1"
  failover_region = "us-west-2"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  environment = "prod"
  name_prefix = "toptal"
  github_repo = "3tire_app_fargate"
  github_repo_env = "prod"
}

ecr = {
  ecr_user = "ecr_user"
  github_repo = "3tire_app_fargate"
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
    assign_public_ip = false
    env_vars = [
      {
        name = "PORT"
        value = 5001
      },
      {
        name = "DB"
        value = "toptal_api"
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
      memory_reservation = 512
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
    autoscaling = {
      enable_autoscaling = true
      max_cpu_threshold = 85
      min_cpu_threshold = 10
      max_cpu_evaluation_period = 3
      min_cpu_evaluation_period = 3
      max_cpu_period = 60
      min_cpu_period = 60
      scale_target_max_capacity = 5
      scale_target_min_capacity = 2
    }
  },
  {
    app_name = "toptal-web"
    port = 8081
    lb_port = 80
    assign_public_ip = false
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
      memory_reservation = 512
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
    autoscaling = {
      enable_autoscaling = true
      max_cpu_threshold = 85
      min_cpu_threshold = 10
      max_cpu_evaluation_period = 3
      min_cpu_evaluation_period = 3
      max_cpu_period = 60
      min_cpu_period = 60
      scale_target_max_capacity = 5
      scale_target_min_capacity = 2
    }
  }
]

fargate = {
  iam_user = "fargate_user"
  user_policies = ["AmazonECS_FullAccess", "AmazonS3FullAccess"]
  ecs_cluster = "toptal-ecs"
  service_log_retention = 30
  privileged = false
  start_timeout = 60
  stop_timeout = 60
}

cdn = {
  name = "3tire_app_cdn"
  s3_bucket_prefix = "toptal-brayan-perera"
  group_origin = "group-cdn"
  primary_origin = "primary-cdn"
  failover_origin = "failover-cdn"
  failover_status_codes = [403, 404, 500, 502]
  origin_access_identity_name = "toptal-3tire-app-cdn"
  log_bucket = "3tire-app-cdn-log-store"
  restriction = {
    restriction_type = "none"
    locations = []
  }
  ttl = {
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }
  description = "Toptal 3Tire app CDN"
  default_root_object = "index.html"
  cache_behavior = {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]
  }
  cdn_user = "toptal_cdn_user"
  github_repo = "3tire_app_fargate"
  github_repo_env = "prod"
}