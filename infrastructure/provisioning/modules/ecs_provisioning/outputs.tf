output "aws_ecs_cluster_cluster_id" {
  value = module.ecs-cluster.aws_ecs_cluster_cluster_id
}

output "aws_ecs_cluster_cluster_arn" {
  value = module.ecs-cluster.aws_ecs_cluster_cluster_arn
}

output "aws_ecs_cluster_cluster_name" {
  value = module.ecs-cluster.aws_ecs_cluster_cluster_name
}

output "task_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}