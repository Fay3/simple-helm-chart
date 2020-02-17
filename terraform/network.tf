resource "aws_subnet" "shc_subnet_private" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.shc_vpc.id

  tags = {
    "Name"                                      = "${var.tag_name}-private-subnet"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}


resource "aws_route_table" "shc_route_table" {
  vpc_id = aws_vpc.shc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.shc_igw.id
  }
}

resource "aws_route_table_association" "shc_rt_association" {
  count = 2

  subnet_id      = aws_subnet.shc_subnet_private[count.index].id
  route_table_id = aws_route_table.shc_route_table.id
}
