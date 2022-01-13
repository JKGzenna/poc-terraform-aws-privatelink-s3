# https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws
module "producer_public_asg" {
  source = "terraform-aws-modules/autoscaling/aws"
  name   = "${var.producer}-public"

  # Launch configuration
  lc_name         = "-lc"
  image_id        = "${data.aws_ami.latest_amzn_ami.id}"
  instance_type   = "t2.small"
  user_data       = "${data.template_file.cloud-init.rendered}"
  security_groups = ["${module.producer_public_security_group.this_security_group_id}"]

  # Auto scaling group
  asg_name                  = "-asg"
  vpc_zone_identifier       = "${module.producer_vpc.public_subnets}"
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "${var.producer}-public"
      propagate_at_launch = true
    },
  ]
}

module "producer_private_asg" {
  source = "terraform-aws-modules/autoscaling/aws"
  name   = "${var.producer}-private"

  # Launch configuration
  lc_name              = "-lc"
  iam_instance_profile = "${aws_iam_instance_profile.producer_asg_profile.id}"
  image_id             = "${data.aws_ami.latest_amzn_ami.id}"
  instance_type        = "t2.small"
  user_data            = "${data.template_file.cloud-init.rendered}"
  security_groups      = ["${module.producer_private_security_group.this_security_group_id}"]

  # Auto scaling group
  asg_name                  = "-asg"
  vpc_zone_identifier       = "${module.producer_vpc.private_subnets}"
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "${var.producer}-private"
      propagate_at_launch = true
    },
  ]
}
