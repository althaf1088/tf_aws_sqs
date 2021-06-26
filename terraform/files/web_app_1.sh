#! /bin/bash
sudo yum install -y docker
sudo service docker start
sudo usermod -aG docker ec2-user
sudo chkconfig docker on
sudo docker run -d -p 80:5000 althaf1088/sgx-1:${version}
