# Code for the creation of a VPC Endpoint and associating it with private route table
resource "aws_vpc_endpoint" "producer_endpoint_gateway_to_s3" {
  route_table_ids = "${module.producer_vpc.private_route_table_ids}"
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_id          = "${module.producer_vpc.vpc_id}"

  # https://docs.aws.amazon.com/vpc/latest/userguide/vpce-gateway.html
  policy = <<POLICY
  {
    "Statement": [
      {
        "Sid": "Access-to-bucket-via-privatelink",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:*",
        "Resource": ["${local.s3_buckets}"]
      }
    ],
    "Version": "2008-10-17"
  }
POLICY

  tags = {
    Name      = "${var.producer}-endpoint-gateway-to-s3"
    Terraform = true
  }
}
