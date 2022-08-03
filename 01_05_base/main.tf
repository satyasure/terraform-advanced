# //////////////////////////////
# VARIABLES
# //////////////////////////////
variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "ssh_key_name" {}

variable "private_key_path" {}

variable "region" {
  default = "eu-west-3"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "subnet-public_cidr" {
  default = "172.16.0.0/24"
}

# //////////////////////////////
# PROVIDERS
# //////////////////////////////
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

# //////////////////////////////
# RESOURCES
# //////////////////////////////

# VPC
resource "aws_vpc" "vpc-development" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = "true"
}

# SUBNET
resource "aws_subnet" "subnet-public" {
  cidr_block              = var.subnet-public_cidr
  vpc_id                  = aws_vpc.vpc-development.id
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[1]
}

# INTERNET_GATEWAY
resource "aws_internet_gateway" "gateway1" {
  vpc_id = aws_vpc.vpc-development.id
}

# ROUTE_TABLE
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc-development.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway1.id
  }
}

resource "aws_route_table_association" "route-subnet-public" {
  subnet_id      = aws_subnet.subnet-public.id
  route_table_id = aws_route_table.route_table_public.id
}

# SECURITY_GROUP
resource "aws_security_group" "sg-nodejs-instance" {
  name   = "nodejs_sg"
  vpc_id = aws_vpc.vpc-development.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

# INSTANCE
resource "aws_instance" "nodejs1" {
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet-public.id
  vpc_security_group_ids = [aws_security_group.sg-nodejs-instance.id]
  key_name               = var.ssh_key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
  }
}


# //////////////////////////////
# DATA
# //////////////////////////////
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# //////////////////////////////
# OUTPUT
# //////////////////////////////
output "instance-dns" {
  value = aws_instance.nodejs1.public_dns
}