resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.db_subnet_group_name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.db_subnet_group_name}-db-subnet-group"
  }

}

resource "aws_db_instance" "rds_instance" {
  instance_class              = var.db_instance_class
  allocated_storage           = var.allocated_storage
  multi_az                    = true
  publicly_accessible         = false
  storage_encrypted           = true
  identifier                  = "${var.db_subnet_group_name}-mysql-instance"
  engine                      = "mysql"
  username                    = var.db_username
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids      = [var.db_security_group_id]
  db_name                     = "appdb"
  port                        = 3306
  skip_final_snapshot         = true
  storage_type                = "gp3"
  backup_window               = "03:00-04:00"
  backup_retention_period     = 1
  deletion_protection         = false # Development environment

  tags = {
    Name = "${var.db_subnet_group_name}-rds-instance"
  }


}