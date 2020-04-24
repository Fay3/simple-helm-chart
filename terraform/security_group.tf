data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  ifconfig_co_json = jsondecode(data.http.my_public_ip.body)
}


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

resource "aws_security_group_rule" "sg_cluster_rule" {
  type                     = "ingress"
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_node.id
  security_group_id        = aws_security_group.sg_cluster.id
}

resource "aws_security_group_rule" "sg_cluster_rule_22" {
  type                     = "ingress"
  description              = "Allow SSH from Bastion"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_bastion.id
  security_group_id        = aws_security_group.sg_cluster.id
}

# NODES SECURITY GROUPS

resource "aws_security_group" "sg_node" {
  description = "EKS node security groups"
  name        = "${var.cluster_name}-node-sg"
  vpc_id      = aws_vpc.shc_vpc.id

  ingress {
    description = "Allow node to communicate with each other"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "${var.cluster_name}-eks-node-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "sg_node_rule" {
  type                     = "ingress"
  description              = "Allow EKS Control Plane"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_cluster.id
  security_group_id        = aws_security_group.sg_node.id
}

resource "aws_security_group_rule" "sg_node_rule_22" {
  type                     = "ingress"
  description              = "Allow SSH from Bastion"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_bastion.id
  security_group_id        = aws_security_group.sg_node.id
}
