resource "aws_lb" "alb" {
  name               = "marlonsp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "marlonsp-alb"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "marlonsp-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    path                = "/docs"
    protocol            = "HTTP"
    port                = "80"
  }

  tags = {
    Name = "marlonsp-target-group"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_launch_template" "lt" {
  name_prefix            = "lt-"
  image_id               = "ami-0230bd60aa48260c6"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  iam_instance_profile {
    name = "ec2_profile"
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "marlonsp-asg"
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  max_size            = 5
  min_size            = 2
  desired_capacity    = 2
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"

  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  tag {
    key                 = "Name"
    value               = "marlonsp-ASG-Instance"
    propagate_at_launch = true
  }
}
