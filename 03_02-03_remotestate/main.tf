# //////////////////////////////
# BACKEND
# //////////////////////////////
terraform {
  backend "s3" {
  }
}

# //////////////////////////////
# VARIABLES
# //////////////////////////////
variable "aws_access_key" {}

variable "aws_secret_key" {}

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
# MODULES
# //////////////////////////////
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-module-example"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}