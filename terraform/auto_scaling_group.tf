resource "aws_autoscaling_group" "shc_autoscaling_group" {
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.shc_launch_config.id
  max_size             = 2
  min_size             = 1
  name                 = "${var.tag_name}"
  vpc_zone_identifier  = "${aws_subnet.shc_subnet_private.*.id}"

  tag {
    key                 = "Name"
    value               = "${var.tag_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

locals {
  shc_node_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.shc_eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.shc_eks.certificate_authority[0].data}' '${var.cluster_name}'
USERDATA

}


resource "aws_launch_configuration" "shc_launch_config" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.shc_iam_instance_profile_node.name
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = "m4.large"
  name_prefix                 = "terraform-eks-shc"
  security_groups             = [aws_security_group.shc_node_sg.id]
  user_data_base64            = base64encode(local.shc_node_userdata)

  lifecycle {
    create_before_destroy = true
  }
}
