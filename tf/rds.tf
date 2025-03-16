data "aws_ssm_parameter" "username" {
  name = "/rds/username"
}

data "aws_ssm_parameter" "password" {
  name = "/rds/password"
}

resource "aws_security_group" "rds" {
  name   = "rds"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "postgres"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
}

resource "aws_db_instance" "rds" {
  identifier             = "postgres"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  username               = data.aws_ssm_parameter.username.value
  password               = data.aws_ssm_parameter.password.value
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
}