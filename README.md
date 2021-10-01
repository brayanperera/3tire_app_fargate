# Sample project For Deploying 3 Tire Application in AWS Cloud

## Overview

This project deploys DB / Web and App components in the AWS Cloud via 
Terraform and maintain the CI/CD via GitHub Actions workflows. 

## Prerequisites 

- Terraform
- GitHub Actions
- AWS
- git

## Initial Setup

1. Using AWS CLI or Console, Create IAM User and Group, and provide necessary access to that user for resource creation. 
2. In a Linux VM / Instance, perform following
   1. Install terraform
   2. Install git
   3. Checkout code
   4. Change to infrastructure/terraform_setup
   5. Update the `terraform.tfvars` based on the requirements
   6. Initialize terraform and apply to setup S3 bucket and DynamoDB instance to maintain tfstate file and locks. 
      1. ````
         terraform init
         terraform plan
         terraform apply
         ````
   7. Change to infrastructure/provisioning
   8. Update the `terraform.tfvars` based on the requirements/environment
   9. Initialize terraform and apply to deploy the AWS infrastructure
      1. ````
         terraform init
         export GITHUB_TOKEN="" # Place your GitHub token
         export GITHUB_ORGANIZATION="" # Place your GitHub Organization 
         terraform plan
         terraform apply
         ````
   10. 