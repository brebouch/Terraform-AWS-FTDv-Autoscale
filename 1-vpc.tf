####################
# VPCs
####################

# Service VPC
resource "aws_vpc" "srvc_vpc" {
  cidr_block           = var.srvc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "${var.env_name} Service VPC"
  }
}

# Service Subnets
resource "aws_subnet" "mgmt_subnet" {
  vpc_id            = aws_vpc.srvc_vpc.id
  cidr_block        = var.mgmt_subnet
  availability_zone = var.aws_az
  tags = {
    Name = "${var.env_name} Service Mgmt Subnet"
  }
}
resource "aws_subnet" "data_subnet" {
  vpc_id            = aws_vpc.srvc_vpc.id
  cidr_block        = var.data_subnet
  availability_zone = var.aws_az
  tags = {
    Name = "${var.env_name} Service Data Subnet"
  }
}
resource "aws_subnet" "lambda_subnet" {
  vpc_id            = aws_vpc.srvc_vpc.id
  cidr_block        = var.lambda_subnet
  availability_zone = var.aws_az
  tags              = {
    Name = "${var.env_name} Lambda Subnet"
  }
}
resource "aws_subnet" "ccl_subnet" {
  vpc_id            = aws_vpc.srvc_vpc.id
  cidr_block        = var.ccl_subnet
  availability_zone = var.aws_az
  tags              = {
    Name = "${var.env_name} Service CCL Subnet"
  }
}

# App VPC
resource "aws_vpc" "app_vpc" {
  cidr_block           = var.app_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "${var.env_name } App VPC"
  }
}
# App Subnets
resource "aws_subnet" "gwlbe_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.gwlbe_subnet
  availability_zone = var.aws_az
  tags = {
    Name = "${var.env_name } GWLBe Subnet"
  }
}
resource "aws_subnet" "app_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.app_subnet
  availability_zone = var.aws_az
  tags = {
    Name = "${var.env_name } App Subnet"
  }
}