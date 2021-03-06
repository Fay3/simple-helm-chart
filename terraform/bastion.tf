resource "aws_launch_configuration" "bastion_launch_conf" {
  name                        = "${var.cluster_name}-bastionasglaunchconfig"
  image_id                    = "ami-035966e8adab4aaad"
  instance_type               = "t3.nano"
  security_groups             = [aws_security_group.sg_bastion.id]
  key_name                    = var.ssh_key_pem
  associate_public_ip_address = true
}

resource "aws_autoscaling_group" "bastion_autoscaling_group" {
  name                      = "${var.cluster_name}-bastionasg"
  launch_configuration      = aws_launch_configuration.bastion_launch_conf.name
  vpc_zone_identifier       = [aws_subnet.shc_public_subnet.0.id, aws_subnet.shc_public_subnet.1.id, aws_subnet.shc_public_subnet.2.id]
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

resource "aws_autoscaling_schedule" "autoscaling_group_up" {
  scheduled_action_name  = "bastion_autoscaling_group_scale_up"
  autoscaling_group_name = aws_autoscaling_group.bastion_autoscaling_group.name
  min_size               = 1
  max_size               = 1
  desired_capacity       = 1
  recurrence             = "0 6 * * MON-FRI"

  depends_on = [aws_autoscaling_group.bastion_autoscaling_group]
}
