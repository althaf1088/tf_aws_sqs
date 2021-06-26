output "elb" {
  value = aws_lb.web-lb.dns_name
}