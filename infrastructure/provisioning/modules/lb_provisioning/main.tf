/* Security Groups for Application LBs */

resource "aws_security_group" "app_sg" {
  
  name        = var.app.app_name
  description = "Security group to allow inbound to ${var.app.app_name} LB"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.app.app_name
    Environment = var.common_config.environment
  }

  ingress = var.app.sec_group_rules

}

/* Log writing bucket for LBs */

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "app_lb_log_bucket" {
  
  bucket = "${var.common_config.aws_account_id}-${var.app.app_name}-log-bucket"
  acl    = "log-delivery-write"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.common_config.aws_account_id}-${var.app.app_name}-log-bucket/${var.app.app_name}/AWSLogs/${var.common_config.aws_account_id}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.common_config.aws_account_id}-${var.app.app_name}-log-bucket/${var.app.app_name}/AWSLogs/${var.common_config.aws_account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${var.common_config.aws_account_id}-${var.app.app_name}-log-bucket"
    }
  ]
}
POLICY

  tags = {
    Name = "${var.app.app_name}-lb-log-bucket"
    Environment = var.common_config.environment
  }
}

resource "aws_lb" "app_lb" {
  
  name               = "${var.app.app_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.default_sec_group_id, aws_security_group.app_sg.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.app_lb_log_bucket.bucket
    prefix  = var.app.app_name
    enabled = true
  }

  tags = {
    Name = "${var.app.app_name}-lb"
    Environment = var.common_config.environment
  }
}

resource "aws_alb_target_group" "app_tg" {
  
  name = "${var.app.app_name}-tg"
  port     = var.app.port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    port     = var.app.port
    protocol = "HTTP"
    timeout  = var.app.health_check.timeout
    interval = var.app.health_check.interval
    healthy_threshold = var.app.health_check.healthy_threshold
    unhealthy_threshold = var.app.health_check.unhealthy_threshold
    path = var.app.health_check.path
  }
}

resource "aws_lb_listener" "app" {
  
  load_balancer_arn = aws_lb.app_lb.arn
  port              = var.app.port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app_tg.arn
  }
}
