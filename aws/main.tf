terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "lab"
}

############# Network #############
# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    "Name" = "${var.environment}-${var.main_vpc_name}"
    "Env" = "${var.environment}"
  }
}

# Subnet
resource "aws_subnet" "web" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.web_subnet
    availability_zone = var.subnet_zone

    tags = {
        "Name" = "${var.environment}-WebSubnet"
        "Env" = "${var.environment}"
    }
}

# Internet Gateway 
resource "aws_internet_gateway" "my_web_igw" {
    vpc_id = aws_vpc.main.id

    tags = {
        "Name" = "${var.environment}-${var.main_vpc_name}-IGW"
    }
}

resource "aws_default_route_table" "main_vpc_default_rt" {
    default_route_table_id = aws_vpc.main.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_web_igw.id
    }

    tags = {
        "Name" = "${var.environment}-MyDefaultRT"
    }
}

resource "aws_default_security_group" "default_sec_group" {
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]
    }

    tags = {
        "Name" = "${var.environment}"
    }
}
