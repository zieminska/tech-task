resource "aws_security_group" "ecs" {
  name   = "ecs"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-*-x86_64"]
  }
}

resource "aws_launch_template" "ecs" {
  name                   = "${var.product_name}-lt"
  image_id               = data.aws_ami.ami.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ecs.id]
  user_data = base64encode(<<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.product_name}-cluster >> /etc/ecs/ecs.config
    EOF
  )
}

resource "aws_autoscaling_group" "ecs_asg" {
  name = "${var.product_name}-asg"
  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id]
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.id
  lb_target_group_arn    = aws_lb_target_group.tg.arn
}

resource "aws_ecs_cluster" "ecs" {
  name = "${var.product_name}-cluster"
}

resource "aws_ecs_task_definition" "ecs" {
  family                   = var.product_name
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([{
    name         = "${var.product_name}-container"
    image        = "${aws_ecr_repository.ecr.repository_url}:latest"
    memory       = 512
    cpu          = 256
    essential    = true
    portMappings = [{ containerPort = 8080, hostPort = 8080 }]
    environment = [
      {
        name  = "USERNAME",
        value = data.aws_ssm_parameter.username.value
      },
      {
        name  = "PASSWORD",
        value = data.aws_ssm_parameter.password.value
      },
      {
        name  = "ENDPOINT",
        value = aws_db_instance.rds.endpoint
      },
      {
        name  = "DATABASE_NAME",
        value = var.db_name
      },
      {
        name  = "PORT",
        value = tostring(var.db_port)
    }]
  }])
}

resource "aws_ecs_service" "ecs" {
  name            = "${var.product_name}-service"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.ecs.arn
  desired_count   = 1
  launch_type     = "EC2"
  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "${var.product_name}-container"
    container_port   = var.container_port
  }
}