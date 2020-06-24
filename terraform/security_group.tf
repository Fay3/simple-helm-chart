data "http" "my_public_ip" {
  url = "https://api.ipify.org?format=json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  ifconfig_co_json = jsondecode(data.http.my_public_ip.body)
}

# BASTION SECURITY GROUPS

resource "aws_security_group" "sg_bastion" {
  description = "Enable internal access to the Bastion device"
  name        = "${var.cluster_name}-bastion-sg"
  vpc_id      = aws_vpc.shc_vpc.id

  ingress {
    description = "SSH from local"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${(local.ifconfig_co_json.ip)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.cluster_name}-bastion-sg"
  }
}

# CLUSTER SECURITY GROUPS

resource "aws_security_group" "sg_cluster" {
  description = "EKS cluster security groups"
  name        = "${var.cluster_name}-cluster-sg"
  vpc_id      = aws_vpc.shc_vpc.id

  ingress {
    description = "Allow local to communicate with the cluster API Server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${(local.ifconfig_co_json.ip)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.cluster_name}-eks-cluster-sg"
  }
}
