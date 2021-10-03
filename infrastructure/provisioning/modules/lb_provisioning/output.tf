output "app_sg_id" {
  value = aws_security_group.app_sg.id
}

output "app_lb" {
  value = aws_lb.app_lb
}

output "app_lb_name" {
  value = aws_lb.app_lb.name
}

output "app_lb_arn" {
  value = aws_lb.app_lb.arn
}

output "app_lb_id" {
  value = aws_lb.app_lb.id
}

output "app_lb_domain" {
  value = aws_lb.app_lb.dns_name
}

output "app_tg" {
  value = aws_alb_target_group.app_tg
}

output "app_tg_id" {
  value = aws_alb_target_group.app_tg.id
}

output "app_tg_name" {
  value = aws_alb_target_group.app_tg.name
}

output "app_tg_arn" {
  value = aws_alb_target_group.app_tg.arn
}