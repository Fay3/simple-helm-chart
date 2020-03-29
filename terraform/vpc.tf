# VPC

data "aws_availability_zones" "available" {
}

resource "aws_vpc" "shc_vpc" {
  cidr_block = var.cidr_block

  tags = {
    "Name"                                      = "${var.cluster_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_internet_gateway" "shc_igw" {
  vpc_id = aws_vpc.shc_vpc.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}
