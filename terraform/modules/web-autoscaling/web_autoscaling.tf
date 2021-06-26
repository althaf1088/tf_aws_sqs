resource "aws_launch_configuration" "web" {


  image_id      = var.image_id
  instance_type = var.instance_type
  iam_instance_profile = var.iam_instance_profile

  key_name        = "my_sgx"
  user_data       = var.user_data
  security_groups = var.security_groups
}


resource "aws_autoscaling_group" "web-asg" {



  max_size             = 2
  min_size             = 2
  desired_capacity     = 2
  force_delete         = true
  launch_configuration = aws_launch_configuration.web.name

  target_group_arns    = var.target_group_arns
  vpc_zone_identifier  = var.vpc_zone_identifier

}