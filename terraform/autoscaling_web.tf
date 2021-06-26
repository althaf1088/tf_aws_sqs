

resource "template_file" "web-1-user-data" {
  template = "${file("files/web_app_1.sh")}"

  vars = {
    version = var.web_app_1_version
  }
}

resource "template_file" "web-2-user-data" {
  template = "${file("files/web_app_2.sh")}"

}

module "web-1-asg" {
  source               = "./modules/web-autoscaling"
  name                 = "web1"
  user_data            = "${template_file.web-1-user-data.rendered}"
  image_id             = var.instance_ami
  instance_type        = var.instance_type
  security_groups      = [aws_security_group.web.id]
  target_group_arns    = [aws_lb_target_group.web-1-tg.arn]
  vpc_zone_identifier  = aws_subnet.private.*.id
  iam_instance_profile = aws_iam_instance_profile.sqs_instance_profile.name

}

module "web-2-asg" {
  source    = "./modules/web-autoscaling"
  name      = "web2"
  user_data = "${template_file.web-2-user-data.rendered}"

  image_id            = var.instance_ami
  instance_type       = var.instance_type
  security_groups     = [aws_security_group.web.id]
  target_group_arns   = [aws_lb_target_group.web-2-tg.arn]
  vpc_zone_identifier = aws_subnet.private.*.id

}
