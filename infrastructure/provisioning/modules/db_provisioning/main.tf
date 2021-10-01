resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = var.subnets

  tags = {
    Name = "Toptal Postgres Access subnets"
  }
}

resource "aws_db_parameter_group" "toptal_app" {
  name   = "toptal_app"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "toptal_app" {
  identifier             = var.rds.instance_name
  instance_class         = var.rds.instance_class
  allocated_storage      = 5
  engine                 = var.rds.engine
  engine_version         = var.rds.engine_version
  username               = var.rds.db_user
  password               = var.rds.db_pass
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = var.security_groups
  parameter_group_name   = aws_db_parameter_group.toptal_app.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}