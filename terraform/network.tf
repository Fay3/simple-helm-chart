### Public Subnets and Routes

resource "aws_subnet" "shc_public_subnet" {
  count = length(var.public_subnets)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.public_subnets[count.index]
  vpc_id            = aws_vpc.shc_vpc.id

  tags = {
    "Name"                                      = "${var.cluster_name}-eks-public"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_route_table" "shc_public_route_table" {
  vpc_id = aws_vpc.shc_vpc.id
  count  = var.az_count

  tags = {
    "Name" = "${var.cluster_name}-rt-public"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.shc_igw.id
  }
}

resource "aws_route_table_association" "shc_public_rt_association" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.shc_public_subnet[count.index].id
  route_table_id = aws_route_table.shc_public_route_table[count.index].id
}

### Private Subnets and Routes

resource "aws_subnet" "shc_private_subnet" {
  count = length(var.private_subnets)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.private_subnets[count.index]
  vpc_id            = aws_vpc.shc_vpc.id

  tags = {
    "Name"                                      = "${var.cluster_name}-eks-private"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_eip" "shc_elastic_ip" {
  count = var.az_count
  vpc   = true
  tags = {
    "Name" = "${var.cluster_name}-eip"
  }
}

resource "aws_nat_gateway" "shc_nat_gateway" {
  count         = var.az_count
  allocation_id = aws_eip.shc_elastic_ip[count.index].id
  subnet_id     = aws_subnet.shc_public_subnet[count.index].id
  tags = {
    "Name" = "${var.cluster_name}-nat-gw"
  }
}

resource "aws_route_table" "shc_private_route_table" {
  count  = var.az_count
  vpc_id = aws_vpc.shc_vpc.id
  tags = {
    "Name" = "${var.cluster_name}-rt-private"
  }
}

resource "aws_route" "private-subnet-default-route" {
  count                  = length(var.private_subnets)
  route_table_id         = aws_route_table.shc_private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.shc_nat_gateway[count.index].id
}

resource "aws_route_table_association" "shc_private_rt_association" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.shc_private_subnet[count.index].id
  route_table_id = aws_route_table.shc_private_route_table[count.index].id
}
