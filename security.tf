# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws
module "producer_public_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.producer}-public-cluster-sg"
  description = "${var.producer} public cluster SG"
  vpc_id      = "${module.producer_vpc.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "http-80-tcp", "https-443-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]


  tags = {
    Name = "${var.producer}-public-cluster-sg"
  }
}

module "producer_private_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.producer}-private-cluster-sg"
  description = "${var.producer} private cluster SG"
  vpc_id      = "${module.producer_vpc.vpc_id}"

  # Only accept ssh connection from the public subnet above
  ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = "${module.producer_public_security_group.this_security_group_id}"
    },
  ]
  # There is no NAT Gateway and so, instances in private subnet will have no route to internet
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["https-443-tcp"]

  tags = {
    Name = "${var.producer}-private-cluster-sg"
  }
}
