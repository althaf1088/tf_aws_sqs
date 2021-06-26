#! /bin/bash
sudo yum install -y docker
sudo service docker start
sudo usermod -aG docker ec2-user
sudo chkconfig docker on
sudo docker run -d  althaf1088/sgx-worker:1.0
