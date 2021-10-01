output "rds_cluster_id" {
  value = aws_db_instance.toptal_db.id
}

output "rds_endpoint" {
  value = aws_db_instance.toptal_db.endpoint
}