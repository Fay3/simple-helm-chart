data "aws_availability_zones" "available" {
}

resource "aws_vpc" "shc_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name"                                      = "${var.tag_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_internet_gateway" "shc_igw" {
  vpc_id = aws_vpc.shc_vpc.id

  tags = {
    Name = "${var.tag_name}-igw"
  }
}
