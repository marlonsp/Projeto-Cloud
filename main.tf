terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket = "marlonsp-bucket"
    key    = "remote-state/terraform.tfstate"
    region = "us-east-1"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

# Criação da VPC
resource "aws_vpc" "projeto_vpc" {
  cidr_block          = "10.0.0.0/16"
  enable_dns_support  = true
  enable_dns_hostnames = true

  tags = {
    Name = "example-vpc"
  }
}

# Criação de subnets públicas
resource "aws_subnet" "public_subnet" {
  count                  = 2
  cidr_block             = "10.0.${count.index + 1}.0/24"
  vpc_id                 = aws_vpc.projeto_vpc.id
  availability_zone      = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Criação de subnets privadas
resource "aws_subnet" "private_subnet" {
  count                  = 2
  cidr_block             = "10.0.${count.index + 3}.0/24"
  vpc_id                 = aws_vpc.projeto_vpc.id
  availability_zone      = element(var.availability_zones, count.index + 1)
  
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Criação de uma Internet Gateway para acesso à internet
resource "aws_internet_gateway" "projeto_igw" {
  vpc_id = aws_vpc.projeto_vpc.id

  tags = {
    Name = "projeto-igw"
  }
}

# Associação da Internet Gateway com as subnets públicas
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.projeto_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.projeto_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_route_association" {
  count             = 2
  subnet_id         = aws_subnet.public_subnet[count.index].id
  route_table_id    = aws_route_table.public_route_table.id
}

# Criação do Application Load Balancer (ALB)
resource "aws_lb" "ec2_lb" {
  name               = "projeto-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2_sg.id]

  enable_deletion_protection = false

  subnet_mapping {
    subnet_id     = aws_subnet.private_subnet[0].id
  }

  subnet_mapping {
    subnet_id     = aws_subnet.private_subnet[1].id
  }

  enable_http2 = true
}


# Output para exibir informações úteis
output "vpc_id" {
  value = aws_vpc.projeto_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"
  count         = 2

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = aws_subnet.private_subnet[count.index].id

  tags = {
    Name = "instancia-${count.index + 1}"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.projeto_vpc.id
}

resource "aws_lb_target_group" "ec2_tg" {
  name     = "ec2-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.projeto_vpc.id

  health_check {
    path                = var.health_check_path
    protocol            = var.health_check_protocol
    port                = 80
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "ec2_tga" {
  count             = length(aws_instance.ec2_instance)
  target_group_arn = aws_lb_target_group.ec2_tg.arn
  target_id        = aws_instance.ec2_instance[count.index].id
}

# Define health check path and protocol
variable "health_check_path" {
  default = "/"
}

variable "health_check_protocol" {
  default = "HTTP"
}

# Create an ALB listener with a health check
resource "aws_lb_listener" "ec2_lb_listener" {
  load_balancer_arn = aws_lb.ec2_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "ec2_lb_listener_rule" {
  listener_arn = aws_lb_listener.ec2_lb_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_tg.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}