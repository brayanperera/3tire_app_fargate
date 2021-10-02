output "ecs_service_id" {
  value = aws_ecs_service.app_service.id
}

output "ecs_service_name" {
  value = aws_ecs_service.app_service.name
}