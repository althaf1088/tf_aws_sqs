resource "aws_instance" "worker" {


  ami                  = var.instance_ami
  instance_type        = var.instance_type
  provider             = aws.region_master
  iam_instance_profile = aws_iam_instance_profile.sqs_instance_profile.name

  key_name                    = "my_sgx"
  user_data                   = file("files/worker.sh")
  vpc_security_group_ids      = [aws_security_group.web.id]
  subnet_id                   = element(aws_subnet.public.*.id, 0)
  associate_public_ip_address = true
}