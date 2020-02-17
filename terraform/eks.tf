resource "aws_eks_cluster" "shc_eks" {
  name     = "${var.cluster_name}"
  role_arn = "${aws_iam_role.shc_iam_role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.shc_cluster_sg.id}"]
    subnet_ids         = "${aws_subnet.shc_subnet_private.*.id}"
  }

  depends_on = [
    "aws_iam_role_policy_attachment.shc_eks_cluster_policy",
    "aws_iam_role_policy_attachment.shc_eks_service_policy",
  ]
}
