output "lb_endpoint" {
  value = aws_lb.marlonsp_alb.dns_name
}