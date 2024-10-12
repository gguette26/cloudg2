resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private-1.id, aws_subnet.private-2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow inbound traffic to RDS"
  vpc_id      = aws_vpc.cloud_vpc.id

  ingress {
    description     = "Allow traffic from EC2 instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.instance_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_rds"
  }
}

resource "aws_db_instance" "default" {
  identifier           = "mydb"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"  # Actualizado a MySQL 8.0
  instance_class       = "db.t3.micro"  # Cambiado a t3.micro
  db_name              = "mydb"
  username             = "admin"
  password             = "passwordTest"  # Recuerda cambiar esto por una contraseña segura
  parameter_group_name = "default.mysql8.0"  # Actualizado para MySQL 8.0
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  tags = {
    Name = "MyRDS"
  }
}

output "db_endpoint" {
  value = aws_db_instance.default.endpoint
}