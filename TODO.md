# Requirement List
 
- [x] Infrastructure provisioning 
  - Using Terraform
- [x] Handling instance failure
  - DB : Using RDS with Multi-AZ deployment Method
- [x] Deploying service / component update without downtime
  - Using Fargate task deployment, which will create new application version, then remove old version tasks.
- [x] Database backups
  - RDS managed backups. Configured while provisioning. 
- [x] Log access
  - Via CloudWatch log groups. 
- [ ] Fork repository
  - Not done, since fork option is disabled. As workaround, downloaded the copy of the sample app. 
- [x] Deploy on AWS
  - Using Terraform AWS provider
- [x] Metric collection
  - Via CloudWatch
  - Added auto-scaling policy
- [x] Using CDN for static content
  - Using CloudFront as CDN and Nodejs Jade template for pushing the CDN URL as ENV variable
- [ ] Architecture diagram and Presentation


# Task List

- [x] Infrastructure provisioning 
  - [X] ECR Provisioning 
  - [x] GitHub Token Provisioning
  - [x] VPC Provisioning
  - [x] DB Provisioning
  - [x] CDN Provisioning
  - [x] Loadbalancer provisioning 
  - [x] Fargate Provisioning
- [x] Using CDN for static content in webapp
- [ ] CI/CD Pipeline
  - [x] Push static files to CDN backend
  - [x] Image creation and push to ECR
  - [x] Update Fargate service
  - [x] Test service status after deploy
- [ ] Documentation
  - [x] Project README.md
  - [x] Architecture diagram 
  - [ ] Presentation