resource "aws_security_group" "web" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  provider    = aws.region_master
  vpc_id      = aws_vpc.vpc_master.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Todo
Add SG of web as source and create another SG for web app