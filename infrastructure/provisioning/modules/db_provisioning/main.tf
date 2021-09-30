resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = var.subnets

  tags = {
    Name = "Toptal Postgres Access subnets"
  }
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier      = var.rds.cluster_name
  engine                  = "aurora-postgresql"
  availability_zones      = var.db_availability_zones
  database_name           = var.rds.db_name
  master_username         = var.rds.db_user
  master_password         = var.rds.db_pass
  backup_retention_period = var.rds.backup_retention_period
  preferred_backup_window = var.rds.preferred_backup_window
  vpc_security_group_ids = var.security_groups
  db_subnet_group_name = aws_db_subnet_group.default.name
}