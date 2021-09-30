resource "aws_security_group" "app_sg" {
  count = length(var.apps)
  name        = var.apps[count.index].app_name
  description = "Security group to allow inbound to ${var.apps[count.index].app_name} LB"
  vpc_id      = var.vpc_id

  tags = {
    Environment = var.common_config.environment
  }

  ingress = var.apps[count.index].sec_group_rules

}

/* Log writing bucket for LBs */

resource "aws_s3_bucket" "app_lb_log_bucket" {
  count = length(var.apps)
  name        = var.apps[count.index].app_name
  bucket = "${var.apps[count.index].app_name}-log-bucket"
  acl    = "log-delivery-write"
}

resource "aws_lb" "app_lb" {
  count = length(var.apps)
  name               = "${var.apps[count.index].app_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.default_sec_group_id, aws_security_group.app_sg[count.index].id]
  subnets            = var.subnet_ids

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.app_lb_log_bucket[count.index].bucket
    prefix  = var.apps[count.index].app_name
    enabled = true
  }

  tags = {
    Environment = var.common_config.environment
  }
}

resource "aws_alb_target_group" "app_tg" {
  count = length(var.apps)
  name = "${var.apps[count.index].app_name}-tg"
  port     = var.apps[count.index].port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    port     = var.apps[count.index].port
    protocol = "HTTP"
    timeout  = var.apps[count.index].health_check.timeout
    interval = var.apps[count.index].health_check.interval
    healthy_threshold = var.apps[count.index].health_check.healthy_threshold
    unhealthy_threshold = var.apps[count.index].health_check.unhealthy_threshold
    path = var.apps[count.index].health_check.path
  }
}

resource "aws_lb_listener" "app" {
  count = length(var.apps)
  load_balancer_arn = aws_lb.app_lb[count.index].arn
  port              = var.apps[count.index].port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app_tg[count.index].arn
  }
}
