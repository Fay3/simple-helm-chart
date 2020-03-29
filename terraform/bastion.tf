resource "aws_launch_configuration" "bastion_launch_conf" {
  name                        = "${var.cluster_name}-bastionasglaunchconfig"
  image_id                    = "ami-0c41e1db3063a5969"
  instance_type               = "t3.nano"
  security_groups             = [aws_security_group.sg_bastion.id]
  key_name                    = var.ssh_key_pem
  associate_public_ip_address = true
}

resource "aws_autoscaling_group" "bastion_autoscaling_group" {
  name                      = "${var.cluster_name}-bastionasg"
  launch_configuration      = aws_launch_configuration.bastion_launch_conf.name
  vpc_zone_identifier       = [aws_subnet.shc_public_subnet.0.id, aws_subnet.shc_public_subnet.1.id]
  health_check_type         = "EC2"
  health_check_grace_period = "60"
  min_size                  = "1"
  max_size                  = "1"
  desired_capacity          = "1"

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-bastion"
      propagate_at_launch = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
}
