resource "aws_sqs_queue" "sgx_queue" {
  provider                  = aws.region_master
  name                      = "sgx"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10


}


resource "aws_iam_role" "sqs_role" {
  name     = "sqs_role"
  provider = aws.region_master
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "sqs_policy" {
  name     = "sqs_policy"
  role     = aws_iam_role.sqs_role.id
  provider = aws.region_master

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [{
      Effect : "Allow",
      Action : "sqs:*",
      Resource : "${aws_sqs_queue.sgx_queue.arn}"
    }],
  })
}
resource "aws_iam_instance_profile" "sqs_instance_profile" {
  provider = aws.region_master
  name     = "sqs_instance_profile"
  role     = aws_iam_role.sqs_role.name
}



