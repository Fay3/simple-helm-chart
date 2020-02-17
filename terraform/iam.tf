resource "aws_iam_role" "shc_iam_role" {
  name = "terraform-eks-shc-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "shc_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.shc_iam_role.name}"
}

resource "aws_iam_role_policy_attachment" "shc_eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.shc_iam_role.name}"
}


resource "aws_iam_instance_profile" "shc_iam_instance_profile_node" {
  name = "terraform-eks-shc-instance-profile"
  role = "${aws_iam_role.shc_iam_role_node.name}"
}


resource "aws_iam_role" "shc_iam_role_node" {
  name = "terraform-eks-shc-node-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "shc_eks_node_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.shc_iam_role_node.name
}

resource "aws_iam_role_policy_attachment" "shc_eks_node_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.shc_iam_role_node.name
}
