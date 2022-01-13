module "producer_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  enable_dns_hostnames             = true
  enable_dns_support               = true
  map_public_ip_on_launch          = true
  enable_dhcp_options              = true
  # No connection to internet from private subnets
  # single_nat_gateway               = true
  # enable_nat_gateway               = true
  cidr                             = "10.0.0.0/25"
  azs                              = "${data.aws_availability_zones.all.names}"
  # private_subnets                  = ["10.0.0.0/27", "10.0.0.32/27"]  # AZ a and b
  # public_subnets                   = ["10.0.0.64/27", "10.0.0.96/27"] # AZ a and b
  private_subnets                  = ["10.0.0.0/27"]  # AZ a
  public_subnets                   = ["10.0.0.64/27"] # AZ a
  dhcp_options_domain_name         = "${var.producer}.internal"
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]

  dhcp_options_tags = {
    Name = "${var.producer}-dhcp"
  }

  vpc_tags = {
    Name = "${var.producer}-vpc"
  }

  public_subnet_tags = {
    Name = "${var.producer}-public_subnets"
  }

  public_route_table_tags = {
    Name = "${var.producer}-public_route_table"
  }

  private_subnet_tags = {
    Name = "${var.producer}-private_subnet"
  }

  private_route_table_tags = {
    Name = "${var.producer}-private_route_table"
  }

  nat_gateway_tags = {
    Name = "${var.producer}-nat_gateway"
  }

  nat_eip_tags = {
    Name = "${var.producer}-nat_eip"
  }

  igw_tags = {
    Name = "${var.producer}-igw"
  }

  tags = {
    Terraform   = "true"
  }
}
