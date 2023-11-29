resource "aws_lb" "marlonsp_alb" {
  name                       = "marlonsp-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.marlonsp_alb_sg.id]
  subnets                    = [aws_subnet.marlonsp_public_subnet_1.id, aws_subnet.marlonsp_public_subnet_2.id]
  depends_on                 = [aws_internet_gateway.marlonsp_igw]
  enable_deletion_protection = false

  tags = {
    Name = "marlonsp-alb"
  }
}

resource "aws_lb_target_group" "marlonsp_tg" {
  name     = "marlonsp-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.marlonsp_vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/docs"
    protocol            = "HTTP"
    port                = "traffic-port"
  }

  tags = {
    Name = "marlonsp-target-group"
  }
}

resource "aws_lb_listener" "marlonsp_listener" {
  load_balancer_arn = aws_lb.marlonsp_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.marlonsp_tg.arn
  }
}

resource "aws_key_pair" "example" {
  key_name   = "marlonsp-key-pair"
  public_key = file("chave-aws.pub")
}

resource "aws_launch_template" "marlonsp_lt" {
  name_prefix   = "marlonsp-lt-"
  image_id      = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.marlonsp_public_subnet_1.id
    security_groups             = [aws_security_group.marlonsp_ec2_sg.id]
  }

  user_data = base64encode(<<-EOF
      #!/bin/bash
      export DEBIAN_FRONTEND=noninteractive

      sudo apt-get update
      sudo apt-get install -y python3-pip python3-venv git

      # Criação do ambiente virtual e ativação
      python3 -m venv /home/ubuntu/myappenv
      source /home/ubuntu/myappenv/bin/activate

      # Clonagem do repositório da aplicação
      git clone https://github.com/ArthurCisotto/aplicacao_projeto_cloud.git /home/ubuntu/myapp

      # Instalação das dependências da aplicação
      pip install -r /home/ubuntu/myapp/requirements.txt

      sudo apt-get install -y uvicorn

      # Configuração da variável de ambiente para o banco de dados
      export DATABASE_URL="mysql+pymysql://dbadmin:password@${aws_db_instance.marlonsp_db_instance.endpoint}/marlonsp_db"

      cd /home/ubuntu/myapp
      # Inicialização da aplicação
      uvicorn main:app --host 0.0.0.0 --port 80 
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "marlonsp-instance"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "marlonsp-asg"
  vpc_zone_identifier = [aws_subnet.marlonsp_public_subnet_1.id, aws_subnet.marlonsp_public_subnet_2.id]
  max_size            = 5
  min_size            = 2
  desired_capacity    = 2
  target_group_arns   = [aws_lb_target_group.marlonsp_tg.arn]
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.marlonsp_lt.id
    version = "$Latest"

  }

  tag {
    key                 = "Name"
    value               = "marlonsp-ASG-Instance"
    propagate_at_launch = true
  }

  # health_check_grace_period = 300
  # force_delete              = true
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_high" {
  alarm_name          = "cpu-utilization-alarm-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "Alarm when CPU exceeds 70%"

  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
  ok_actions    = [aws_autoscaling_policy.scale_down.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_low" {
  alarm_name          = "cpu-utilization-alarm-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "Alarm when CPU is less than 20%"

  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
  ok_actions    = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}
