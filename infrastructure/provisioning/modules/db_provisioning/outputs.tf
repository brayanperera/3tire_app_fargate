output "rds_cluster_id" {
  value = aws_rds_cluster.rds_cluster.id
}

output "rds_endpoint" {
  value = aws_rds_cluster.rds_cluster.endpoint
}

output "rds_read_endpoint" {
  value = aws_rds_cluster.rds_cluster.reader_endpoint
}