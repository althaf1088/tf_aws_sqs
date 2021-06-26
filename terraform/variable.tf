variable "profile" {
  type    = string
  default = "default"
}


variable "region_master" {
  type    = string
  default = "us-east-1"
}

variable "region_worker" {
  type    = string
  default = "us-west-2"
}


variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "vpc_cidr_master" {
  default = "10.20.0.0/16"
}

variable "vpc_name_master" {
  default = "vpc_master"
}

variable "vpc_cidr_worker" {
  default = "30.30.0.0/16"
}

variable "vpc_name_worker" {
  default = "vpc_worker"
}


variable "public_subnets_cidr" {
  type    = list
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnets_cidr" {
  type    = list
  default = ["10.20.3.0/24", "10.20.4.0/24"]
}

variable "azs" {
  type    = list
  default = ["us-east-1a", "us-east-1b"]
}


variable "azs_worker" {
  type    = list
  default = ["us-west-1a", "us-west-1b"]
}

variable "public_subnets_cidr_worker" {
  type    = list
  default = ["30.20.1.0/24", "30.20.2.0/24"]
}

variable "private_subnets_cidr_worker" {
  type    = list
  default = ["30.30.3.0/24", "30.30.4.0/24"]
}

variable "instance_ami" {
  default = "ami-0ab4d1e9cf9a1215a"
}

variable "web_app_1_version" {
  default = "2.0"
}