output "lb_endpoint" {
  value = "http://${aws_lb.marlonsp_alb.dns_name}/docs"
}