resource "aws_db_instance" "marlonsp_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  username             = "databaseteste"
  password             = "password"
  port                 = "3306"
  identifier           = "terraform-database-marlonsp"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = "true"

  publicly_accessible = false

  db_subnet_group_name   = aws_db_subnet_group.marlonsp_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  backup_retention_period = 7
  backup_window           = "02:00-03:00"
  maintenance_window      = "Mon:03:00-Mon:04:00"

  multi_az = true
}


resource "aws_db_subnet_group" "marlonsp_db_subnet_group" {
  name       = "marlonsp-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "marlonsp - DB Subnet Group"
  }
}
