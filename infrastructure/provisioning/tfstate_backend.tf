terraform {
  backend "s3" {
    bucket         = "toptal-tire3-app-brayan-tf-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "toptal_3tire_app_infra_locks"
    encrypt        = true
  }
}