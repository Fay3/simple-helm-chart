locals {
  shc_node_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.shc_eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.shc_eks.certificate_authority.0.data}' '${var.cluster_name}'
USERDATA
}

resource "aws_launch_configuration" "shc_launch_conf" {
  name                        = "${var.cluster_name}-shcasglaunchconfig"
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = "t3.medium"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.node.name
  security_groups             = [aws_security_group.sg_node.id]
  user_data_base64            = base64encode(local.shc_node_userdata)

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "shc_autoscaling_group" {
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.shc_launch_conf.id
  max_size             = 2
  min_size             = 1
  name                 = var.cluster_name
  vpc_zone_identifier  = [aws_subnet.shc_private_subnet.0.id, aws_subnet.shc_private_subnet.1.id]

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}



