resource "aws_eks_cluster" "shc_eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.sg_cluster.id]
    subnet_ids         = flatten([aws_subnet.shc_public_subnet.*.id, aws_subnet.shc_private_subnet.*.id])
  }

  tags = {
    "Name"                                      = "${var.cluster_name}-eks"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,
  ]
}

resource "aws_eks_node_group" "shc_eks_node" {
  cluster_name    = aws_eks_cluster.shc_eks.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.shc_private_subnet.*.id
  instance_types = ["t3.medium"]
  remote_access {
    ec2_ssh_key = var.ssh_key_pem
    source_security_group_ids  = [aws_security_group.sg_bastion.id]
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    "Name"                                      = "${var.cluster_name}-worker-node"
  }
}
