# Sample project For Deploying 3 Tire Application in AWS Cloud

## Overview

This project deploys DB / Web and App components in the AWS Cloud via 
Terraform and maintain the CI/CD via GitHub Actions workflows. 

## Prerequisites 

- Terraform
- GitHub Actions
- AWS
  - ECR - Container Registry
  - RDS - Database server backend
  - Cloudfront - CDN
  - Fargate - Container Runtime
  - Cloudwatch - Logs and System metric collector
- git

> **Note:** This project is using GitHub repository to manage the CI/CD pipelines. 
> Therefore code to be pushed to a GitHub repository

## Architecture

### Application High-Level Architecture 
![application_architecture](docs/diagrams/application_architecture.png)

### IaC and CI/CD Architecture 
![iac_cicd_architecture](docs/diagrams/iac_cicd_architecture.png)

### Deployment Architecture 
![deployment_architecture](docs/diagrams/deployment_architecture.png)

## Initial Setup

1. Using AWS CLI or Console, Create IAM User and Group, and provide necessary access to that user for resource creation. 
   use the collected details as AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_DEFAULT_REGION env variables.  
2. Prepare GitHub repository and create access token
3. In a Linux VM / Instance, perform following
   1. Install terraform
   2. Install git
   3. Clone repo and Checkout code
   4. Change to infrastructure/terraform_setup
   5. Update the `terraform.tfvars` based on the requirements
   6. Initialize terraform and apply to setup S3 bucket and DynamoDB instance to maintain tfstate file and locks. 
      Use appropriate values for following ENV variables. 
      1. ````
         export AWS_ACCESS_KEY_ID="" # Place your IAM user Access key that generated in step 1
         export AWS_SECRET_ACCESS_KEY="" # Place your IAM user secret key that generated in step 1
         export AWS_DEFAULT_REGION="" # Place your AWS Region

         terraform init
         terraform plan
         terraform apply
         ````
   7. Change to infrastructure/provisioning
   8. Update the `terraform.tfvars` based on the requirements/environment
   9. Initialize terraform and apply to deploy the AWS infrastructure
      1. ````
          export AWS_ACCESS_KEY_ID="" # Place your IAM user Access key that generated in step 1
          export AWS_SECRET_ACCESS_KEY="" # Place your IAM user secret key that generated in step 1
          export AWS_DEFAULT_REGION="" # Place your AWS Region
          export GITHUB_TOKEN="" # Place your GitHub token
          export GITHUB_ORGANIZATION="" # Place your GitHub Organization 
          export GITHUB_OWNER="" # Place your GitHub Organization 
            
          terraform init
          terraform plan
          terraform apply
          ````

### Variables

This project uses set of variables for infrastructure provisioning. Please see the below. 

- **`common_config`**: 
  - **Type:** ``object``
  - **Description:** Common config elements for all the submodules
  - **Content**:
    ````
    {
      aws_account_id = number
      region = string
      failover_region = string
      availability_zones = list(string)
      environment = string
      name_prefix = string
      github_repo = string
      github_repo_env = string
    }
    ````
 
 
- **`ecr`**:
  - **Type:** ``object``
  - **Description:** ECR provisioning module related variables
  - **Content**:
    ````
    {
      ecr_user = string
    }
    ````


- **`vpc`**:
  - **Type:** ``object``
  - **Description:**  VPC provisioning configs
  - **Content**:
    ````
    {
      vpc_name = string
      vpc_cidr = string
      public_subnets_cidr = list(string)
      private_subnets_cidr = list(string)
    }
    ````


- **`rds`**:
  - **Type:** ``object``
  - **Description:** RDS provisioning variables for Postgres database
  - **Content**:
    ````
    {
      instance_name = string
      instance_class = string
      allocated_storage = number
      storage_type = string
      engine = string
      engine_version = string
      db_name = string
      db_user = string
      db_pass = string
      backup_retention_period = number
      backup_window = string
      maintenance_window = string
    }
    ````


- **`apps`**:
  - **Type:** ````
  - **Description:** 
  - **Content**:
    ````
    {
      app_name = string
      port = number
      lb_port = number
      assign_public_ip = bool
      env_vars = list(object({
        name = string
        value = string
      }))
      health_check = object({
        path = string
        interval = number
        timeout = number
        healthy_threshold = number
        unhealthy_threshold = number
      })
      module_dir = string
      working_directory = string
      service_config = object({
        cpu = number
        memory = number
        count = number
        memory_reservation = number
      })
      sec_group_rules = list(object({
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_blocks  = list(string)
        ipv6_cidr_blocks = list(string)
        prefix_list_ids = list(string)
        security_groups = list(string)
        self = bool
        description = string
      }))

      autoscaling = object({enable_autoscaling = bool
        max_cpu_threshold = number
        min_cpu_threshold = number
        max_cpu_evaluation_period = string
        min_cpu_evaluation_period = string
        max_cpu_period = number
        min_cpu_period = string
        scale_target_max_capacity = number
        scale_target_min_capacity = number})
    }
    ````


- **`fargate`**:
  - **Type:** ``object``
  - **Description:** Fargate provisioning configs
  - **Content**:
    ````
    {
      user_policies = list(string)
      iam_user = string
      ecs_cluster = string
      service_log_retention = number
      privileged = bool
      start_timeout = number
      stop_timeout  = number
    }
    ````

     
- **`cdn`**:
  - **Type:** ``object``
  - **Description:** 
  - **Content**:
    ````
    {
      name = string
      s3_bucket_prefix = string
      group_origin = string
      primary_origin = string
      failover_origin = string
      failover_status_codes = list(number)
      origin_access_identity_name = string
      log_bucket = string
      restriction = object({
        restriction_type = string
        locations = list(string)
      })
      ttl = object({
        min_ttl = number
        default_ttl = number
        max_ttl = number
      })
      description = string
      default_root_object = string
      cache_behavior = object({
        allowed_methods = list(string)
        cached_methods = list(string)
      })
      cdn_user = string
    }
    ````
    
## Execution Workflow

### Terraform Setup

This step creates S3 backend for Terraform TFState file management. 

````plantuml
@startuml
start
:Create S3 bucket for TFState file store;
:Create DynamoDB database for TF state lock storing;
stop
@enduml
````


### Infrastructure Provisioning

This step is deploying and configure the AWS and GitHub environment for the application deployment. 

````plantuml
@startuml
start
:Create ECR Resources and Provision GitHub secrets;
:Create VPC, Subnets, NAT and Internet GWs,
 and Security Groups;
:Create RDS Postgres Multi-AZ deployment;
:Create ECS Cluster and IAM resources ;
:Create S3 Origins and Cloudfront distribition for CDN. 
Configure GitHub Secrets;
:Create loadbalancers for API and Web services;
:Create IAM resources, Fargate service and Autoscalling. 
Configure GitHub Secrets;
stop
@enduml
````

#### ECR Provisioning

````plantuml
@startuml
start
:Create IAM User `ecr_user`;
:Create IAM User policy for `ecr_user`;
:Create access key for `ecr_user`;
:Create ECR repository;
:Create GitHub secrets for Access Key and Secret;
stop
@enduml
````

#### VPC Provisioning

````plantuml
@startuml
start
:Create VPC;
:Create Public Subnets;
:Create Private Subnets;
:Create Internet GW;
:Create Elastic IPs for NatGWs;
:Create NatGW per private subnet;
:Create public route table;
:Create Route table per private subnet;
:Create route for public route table;
:Create route for private route tables;
:Create route table association for public subnets;
:Create route table association for private subnets;
:Create AWS log group for flow logs;
:Create IAM role and policy for vpc logs;
:Create VPC Flow logs;
stop
@enduml
````


#### RDS Provisioning

````plantuml
@startuml
start
:Create DB Subnet group;
:Create DB parameter group;
:Create Postgres RDS DB instance with Multi-AZ;
stop
@enduml
````


#### ECS Provisioning

````plantuml
@startuml
start
:Create ecsTaskExecutionRole ;
:Attach AmazonECSTaskExecutionRolePolicy to ecsTaskExecutionRole;
:Create `fargate_user` IAM user;
:Attached supplied policies to the user;
:Create Access key for the user;
:Create ECS Cluster;
:Create GitHub secrets for Access key and secret of fargate user;

stop
@enduml
````

#### CDN Provisioning

````plantuml
@startuml
start
: Create Create S3 buckets for Primary and Failover origins ;
: Create a bucket for CDN Access logs;
: Create IAM user and attach pilicies to access the buckets;
: Create bucket policies;
: Create access key for the CDN user;
: Create Cloudfront Origin access identity;
: Create Cloudfront Distribution;
: Create GitHub Access key and Secret;
: Configure CDN domain name as secret in GitHub;
stop
@enduml
````

#### ALB Provisioning

````plantuml
@startuml
start
: Create AWS Security Group for the ALB;
: Create S3 bucket for ALB log writing;
: Create Application loadbalancer;
: Create a target group for the application service;
: Create ALB listner pointing to the target group ;
stop
@enduml
````


#### Fargate provisioning

````plantuml
@startuml
start
: Create AWS Cloudwatch log group;
: Generate Container Definition;
: Create task definition; 
: Create ECS/Fargate Service;
: Create Cloudwatch metric alarm, Scalling policy and Scaling target for each service;
stop
@enduml
````

### GitHub Action Flow

This is invoked when master branch get a git push. 

#### Upload CDN Content
```plantuml
@startuml
start
: Checkout Repository ;
: Upload `web/public` content to Primary and Secondary S3 buckets;
stop
@enduml
```

#### Image creation, push and Fargate Task update
```plantuml
@startuml
start
: Checkout Repository ;
: Configure AWS Credentials for ECR. 
Use AWS_ECR_USER_ACCESS_KEY and 
AWS_ECR_USER_SECRET_KEY secrets;
: Login to ECR;
: Build, tag and push images to ECR;
: Configure AWS Credentials for Fargate. 
Use AWS_FARGATE_USER_ACCESS_KEY and 
AWS_FARGATE_USER_SECRET_KEY secrets;
: Get ECS Task definitian;
: Add new Image to the task definition ;
: Deploy New Task Definition version;
: Check service Status;
: Send an Email if service check failed;
stop
@enduml
```