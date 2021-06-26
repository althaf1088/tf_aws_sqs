resource "aws_lb" "web-lb" {
  provider           = aws.region_master
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id

  security_groups = [aws_security_group.web.id]

  enable_deletion_protection = true

  //  access_logs {
  //    bucket  = aws_s3_bucket.lb_logs.bucket
  //    prefix  = "test-lb"
  //    enabled = true
  //  }

  tags = {
    Name = "Web"
  }
}

resource "aws_lb_target_group" "web-1-tg" {
  provider = aws.region_master
  name     = "web-1-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_master.id
  health_check {
    path = "/app1"
    port = 80
  }
}
//
//resource "aws_lb_target_group_attachment" "web-1-tg-att" {
//  provider         = aws.region_master
//  target_group_arn = aws_lb_target_group.web-1-tg.arn
//  target_id        = aws_instance.web1.id
//  port             = 80
//}

resource "aws_lb_target_group" "web-2-tg" {
  provider = aws.region_master
  name     = "web-2-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_master.id
  health_check {
    path = "/app2"
    port = 80
  }
}

//resource "aws_lb_target_group_attachment" "web-2-tg-att" {
//  provider         = aws.region_master
//  target_group_arn = aws_lb_target_group.web-2-tg.arn
//  target_id        = aws_instance.web2.id
//  port             = 80
//}

resource "aws_lb_listener" "web" {
  provider          = aws.region_master
  load_balancer_arn = aws_lb.web-lb.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-1-tg.arn
  }
}

resource "aws_lb_listener_rule" "web1" {
  provider     = aws.region_master
  listener_arn = aws_lb_listener.web.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-1-tg.arn
  }

  condition {
    path_pattern {
      values = ["/app1*"]
    }
  }

}

resource "aws_lb_listener_rule" "web2" {
  provider     = aws.region_master
  listener_arn = aws_lb_listener.web.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-2-tg.arn
  }

  condition {
    path_pattern {
      values = ["/app2*"]
    }
  }

}