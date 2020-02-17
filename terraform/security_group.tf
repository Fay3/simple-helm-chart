resource "aws_security_group" "shc_cluster_sg" {
  name        = "terraform-eks-shc-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.shc_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tag_name}-sg"
  }
}

data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  ifconfig_co_json = jsondecode(data.http.my_public_ip.body)
}



resource "aws_security_group_rule" "shc_443_ingress_sg" {
  cidr_blocks       = ["${(local.ifconfig_co_json.ip)}/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.shc_cluster_sg.id}"
  to_port           = 443
  type              = "ingress"
}



resource "aws_security_group" "shc_node_sg" {
  name        = "terraform-eks-shc-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.shc_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                      = "${var.tag_name}-node-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}


resource "aws_security_group_rule" "shc_node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.shc_node_sg.id
  source_security_group_id = aws_security_group.shc_node_sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "shc_node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control      plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.shc_node_sg.id
  source_security_group_id = aws_security_group.shc_cluster_sg.id
  to_port                  = 65535
  type                     = "ingress"
}


resource "aws_security_group_rule" "shc_cluster_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.shc_cluster_sg.id
  source_security_group_id = aws_security_group.shc_node_sg.id
  to_port                  = 443
  type                     = "ingress"
}
