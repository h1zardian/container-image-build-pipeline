resource "aws_db_subnet_group" "pipeline_database_sng" {
  name       = "pipeline_database_sng"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "database subnet group"
  }
}

resource "aws_db_instance" "pipeline_database" {
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "postgres"
  engine_version          = "14.8"
  instance_class          = "db.t3.micro"
  name                    = var.db_name
  username                = var.db_username
  password                = var.db_password
  parameter_group_name    = "default.postgres14"
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.database_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.pipeline_database_sng.name
  backup_retention_period = 0     # disable automated backups
  multi_az                = false # disable Multi-AZ deployment
  tags = {
    Name = "pipeline-database"
  }
}

resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Allow inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}