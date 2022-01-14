# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws

resource "aws_s3_bucket" "log_bucket" {
  # The name of the bucket that will receive the log objects
  bucket = "log-${var.producer_s3_bucket_name}"
  acl = "log-delivery-write"
}

# resource "aws_s3_bucket_public_access_block" "log_bucket_bucket_public_block" {
#   bucket = "${aws_s3_bucket.log_bucket.id}"
#
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

module "privatelink_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = "${var.producer_s3_bucket_name}"
  acl           = "private"
  force_destroy = true
  region        = "${data.aws_region.current.name}"

  logging_inputs = [
    {
      target_bucket = "${aws_s3_bucket.log_bucket.id}"
      target_prefix = "access-logs/"
    },
  ]

  versioning_inputs = [
    {
      enabled    = true
      mfa_delete = null
    },
  ]

  request_payer = "Requester"

  server_side_encryption_configuration_inputs = [
    {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = "${aws_kms_key.producer_kms_key.arn}"
    },
  ]

  tags = {
    Terraform = "true"
    Name = "privatelink-s3-bucket"
  }
}

resource "aws_s3_bucket_policy" "producer_bucket_policy" {
  bucket = "${module.privatelink_s3_bucket.id}"

  depends_on = [ "aws_s3_bucket_public_access_block.producer_bucket_public_block" ]

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Access-to-specific-VPCE-only",
            "Principal": {
                "AWS": "${aws_iam_role.producer_asg_role.arn}"
            },
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject"
            ],
            "Effect": "Deny",
            "Resource": ["${local.s3_buckets}"],
            "Condition": {
                "StringNotEquals": {
                    "aws:sourceVpce": "${aws_vpc_endpoint.producer_endpoint_gateway_to_s3.id}"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "producer_bucket_public_block" {
  bucket = "${module.privatelink_s3_bucket.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
