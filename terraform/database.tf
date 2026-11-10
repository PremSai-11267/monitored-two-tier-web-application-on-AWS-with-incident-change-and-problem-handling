
# PostgreSQL database for Life Sciences
# Private subnets for Amazon RDS PostgreSQL
resource "aws_db_subnet_group" "main" {
  name = "lifesciences-db-subnet-group"

  subnet_ids = [
    aws_subnet.private["a"].id,
    aws_subnet.private["b"].id
  ]

  tags = {
    Name = "LifeSciences-DB-Subnet-Group"
  }
}
resource "aws_db_instance" "postgres" {
  identifier     = "lifesciences-postgres-lab"
  engine         = "postgres"
  instance_class = "db.t4g.micro"

  db_name  = "lifesciences"
  username = "dbadmin"

  # AWS manages the master password
  manage_master_user_password = true

  # Database storage
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  # Private networking
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  port                   = 5432

  # Lab configuration
  multi_az                = false
  backup_retention_period = 1
  deletion_protection     = false
  skip_final_snapshot     = true

  tags = {
    Name = "LifeSciences-PostgreSQL"
  }
}
