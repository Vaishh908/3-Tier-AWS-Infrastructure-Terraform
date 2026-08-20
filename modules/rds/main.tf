resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name}-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier             = var.name
  engine                 = "mysql"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  storage_type           = "gp3"
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  port                   = 3306
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]

  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  multi_az               = false

  tags = {
    Name = var.name
  }
}
