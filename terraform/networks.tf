#Create VPC in us-east-1
resource "aws_vpc" "vpc_master" {
  provider             = aws.region_master
  cidr_block           = var.vpc_cidr_master
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name_master
  }
}

//#Create VPC in us-west-2
//resource "aws_vpc" "vpc_worker" {
//  provider             = aws.region_worker
//  cidr_block           = var.vpc_cidr_worker
//  enable_dns_support   = true
//  enable_dns_hostnames = true
//  tags = {
//    Name = var.vpc_name_worker
//  }
//
//}

#Create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc_master.id
}

//#Create IGW in us-west-2
//resource "aws_internet_gateway" "igw-worker" {
//  provider = aws.region_worker
//  vpc_id   = aws_vpc.vpc_worker.id
//}


# Create public subnet # 1 in us-east-1
resource "aws_subnet" "public" {
  provider                = aws.region_master
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.vpc_master.id
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Tier = "Public"
  }
}

# Create private subnet # 1 in us-east-1
resource "aws_subnet" "private" {
  provider                = aws.region_master
  count                   = length(var.private_subnets_cidr)
  vpc_id                  = aws_vpc.vpc_master.id
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

}

# Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  provider   = aws.region_master
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

# NAT
resource "aws_nat_gateway" "nat" {
  provider      = aws.region_master
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "nat"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {

  provider = aws.region_master
  vpc_id   = aws_vpc.vpc_master.id
  tags = {
    Name = "private-route-table"
  }
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc_master.id
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route" "public_internet_gateway" {
  provider               = aws.region_master
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route" "private_nat_gateway" {
  provider               = aws.region_master
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

/* Route table associations */
resource "aws_route_table_association" "public" {
  provider       = aws.region_master
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  provider       = aws.region_master
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}



//# Route table: attach Internet Gateway
//resource "aws_route_table" "public_rt" {
//  vpc_id = "${aws_vpc.vpc_master.id}"
//
//  route {
//    cidr_block = "0.0.0.0/0"
//    gateway_id = "${aws_internet_gateway.igw.id}"
//  }
//
//  tags {
//    Name = "publicRouteTable"
//  }
//}
//
//resource "aws_default_route_table" "private_rt" {
//  default_route_table_id = "${aws_vpc.terra_vpc.default_route_table_id}"
//
//  tags {
//    Name = "sc_private"
//  }
//}
//# Route table association with public subnets
//resource "aws_route_table_association" "a" {
//  count          = "${length(var.subnets_cidr)}"
//  subnet_id      = "${element(aws_subnet.public.*.id,count.index)}"
//  route_table_id = "${aws_route_table.public_rt.id}"
//}
//
//# Route table association with private subnets
//resource "aws_route_table_association" "b" {
//  count          = "${length(var.private_subnets_cidr)}"
//  subnet_id      = "${element(aws_subnet.private.*.id,count.index)}"
//  route_table_id = "${aws_default_route_table.private_rt.id}"
//}
//
////
////#Create route table in us-east-1
////resource "aws_route_table" "internet_route" {
////  provider = aws.region-master
////  vpc_id   = aws_vpc.vpc_master.id
////  route {
////    cidr_block = "0.0.0.0/0"
////    gateway_id = aws_internet_gateway.igw.id
////  }
////  lifecycle {
////    ignore_changes = all
////  }
////  tags = {
////    Name = "Master-Region-internet-RT"
////  }
////}
////
////# Route table association with public subnets
////resource "aws_route_table_association" "public_subnet_association" {
////  provider       = aws.region-master
////  subnet_id      = aws_subnet.public.id
////  route_table_id = aws_route_table.internet_route.id
////}
////
////#Create subnet in us-west-2
////resource "aws_subnet" "subnet_1_oregon" {
////  provider   = aws.region-worker
////  vpc_id     = aws_vpc.vpc_master_oregon.id
////  cidr_block = "192.168.1.0/24"
////}
////
////
////#Initiate Peering connection request from us-east-1
////resource "aws_vpc_peering_connection" "useast1-uswest2" {
////  provider    = aws.region-master
////  peer_vpc_id = aws_vpc.vpc_master_oregon.id
////  vpc_id      = aws_vpc.vpc_master.id
////  peer_region = var.region-worker
////
////}
////
////#Accept VPC peering request in us-west-2 from us-east-1
////resource "aws_vpc_peering_connection_accepter" "accept_peering" {
////  provider                  = aws.region-worker
////  vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
////  auto_accept               = true
////}
////
////#Create route table in us-east-1
////resource "aws_route_table" "peer_route" {
////  provider = aws.region-master
////  vpc_id   = aws_vpc.vpc_master.id
////  route {
////    cidr_block                = "192.168.1.0/24"
////    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
////  }
////  lifecycle {
////    ignore_changes = all
////  }
////  tags = {
////    Name = "Master-Region-RT"
////  }
////}
////
////#Overwrite default route table of VPC(Master) with our route table entries
////resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
////  provider       = aws.region-master
////  vpc_id         = aws_vpc.vpc_master.id
////  route_table_id = aws_route_table.peer_route.id
////}
////
////#Create route table in us-west-2
////resource "aws_route_table" "peer_route_oregon" {
////  provider = aws.region-worker
////  vpc_id   = aws_vpc.vpc_master_oregon.id
////  route {
////    cidr_block                = "10.0.1.0/24"
////    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
////  }
////  lifecycle {
////    ignore_changes = all
////  }
////  tags = {
////    Name = "Worker-Region-RT"
////  }
////}
////
////#Overwrite default route table of VPC(Worker) with our route table entries
////resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
////  provider       = aws.region-worker
////  vpc_id         = aws_vpc.vpc_master_oregon.id
////  route_table_id = aws_route_table.peer_route_oregon.id
////}
//
