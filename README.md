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
  - **Content**
    - `aws_account_id`
      - **Type:** ``number``
      - **Description:** AWS Account ID
    - ``region``:
      - **Type:** ``string``
      - **Description:** Default AWS Region
    - ``availability_zones``
      - **Type:** ``list(string)``
      - **Description:** List of Availability Zones ["us-east-1a", "us-east-1b", "us-east-1c"]
    - ``environment``
      - **Type:** ``string``
      - **Description:** Deployment environment name.

- **`ecr`**:
  - **Type:** ``object``
  - **Description:** ECR provisioning module related variables
  - **Content**   
    - `ecr_user`
        - **Type:** ``string``
        - **Description:** IAM user to be created and provisioned in GitHub for container push
    - `github_repo`
        - **Type:** ``string``
        - **Description:** GitHub repository name. ``GITHUB_TOKEN``, `GITHUB_ORGANIZATION`, and `GITHUB_OWNER` environment variables must present.
    - `github_repo_env`
        - **Type:** ``string``
        - **Description:** GitHub Actions environment
- **`vpc`**:
  - **Type:** ``object``
  - **Description:**  VPC provisioning configs
  - **Content**   
    - `vpc_name`
        - **Type:** ``string``
        - **Description:** VPC name to be created
    - `vpc_cidr`
        - **Type:** ``string``
        - **Description:** VPC Network CIDR
    - `public_subnets_cidr`
        - **Type:** ``list(string)``
        - **Description:** Public subnet CIDR list ["10.0.20.0/24"]
    - `private_subnets_cidr`
        - **Type:** ``list(string)``
        - **Description:** Private subnet CIDR list ["10.0.10.0/24"]
- **`rds`**:
  - **Type:** ``object``
  - **Description:** RDS provisioning variables for Postgres database
  - **Content**   
    - `instance_name`
        - **Type:** ``string``
        - **Description:**  RDS DB name 
    - `instance_class`
        - **Type:** ``string``
        - **Description:** DB server size
    - `allocated_storage`
        - **Type:** ``number``
        - **Description:**   DB size
    - `storage_type`
        - **Type:** ``string``
        - **Description:** Storage type
    - `engine`
        - **Type:** ``string`` 
        - **Description:** DB type. "postgres"
    - `engine_version`
        - **Type:** ``string``
        - **Description:** DB version
    - `db_name`
        - **Type:** ``string``
        - **Description:** Database name
    - `db_user`
        - **Type:** ``string``
        - **Description:**   DB user
    - `db_pass`
        - **Type:** ``string``
        - **Description:**   DB pass
    - `backup_retention_period`
        - **Type:** ``string``
        - **Description:**   Backup keeping time in days
    - `backup_window`
        - **Type:** ``string`` 
        - **Description:**  Backup window. E.g: "01:00-03:00"
    - `maintenance_window`
        - **Type:** ``string``
        - **Description:**   Maintainance window. E.g:"mon:04:00-mon:06:00"
- **`apps`**:
  - **Type:** ````
  - **Description:** 
  - **Content**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**  
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
- **`fargate`**:
  - **Type:** ``object``
  - **Description:** Fargate provisioning configs
  - **Content**   
    - `iam_group`
        - **Type:** ``string``
        - **Description:** IAM group which 
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**  
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**  
    - ``
        - **Type:** ````
        - **Description:**   
- **`cdn`**:
  - **Type:** ````
  - **Description:** 
  - **Content**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
    - ``
        - **Type:** ````
        - **Description:**   
## Execution Workflow

### 