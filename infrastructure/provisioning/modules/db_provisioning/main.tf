resource "aws_db_subnet_group" "toptal_db_subnet" {
  name       = "toptal_db_subnet"
  subnet_ids = var.subnets

  tags = {
    Name = "Toptal Postgres Access subnets"
    Environment = var.common_config.environment
  }
}

resource "aws_db_parameter_group" "toptal_db" {
  name   = "toptal-db"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "toptal_db" {
  identifier             = var.rds.instance_name
  instance_class         = var.rds.instance_class
  allocated_storage      = var.rds.allocated_storage
  engine                 = var.rds.engine
  engine_version         = var.rds.engine_version
  name                   = var.rds.db_name
  username               = var.rds.db_user
  password               = var.rds.db_pass
  db_subnet_group_name   = aws_db_subnet_group.toptal_db_subnet.name
  vpc_security_group_ids = var.security_groups
  parameter_group_name   = aws_db_parameter_group.toptal_db.name
  skip_final_snapshot    = true
  backup_retention_period = var.rds.backup_retention_period
  backup_window     = var.rds.backup_window
  maintenance_window = var.rds.maintenance_window
  multi_az = true

  tags = {
    Name = var.rds.instance_name
    Environment = var.common_config.environment
  }
}