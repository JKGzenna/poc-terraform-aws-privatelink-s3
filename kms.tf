resource "aws_kms_alias" "producer_kms_key" {
  name          = "alias/${var.producer}_kms_key"
  target_key_id = "${aws_kms_key.producer_kms_key.key_id}"
}

resource "aws_kms_key" "producer_kms_key" {
  description             = "keys for used by ${var.producer} for SSE of buckets"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = <<EOF
  {
      "Version": "2012-10-17",
      "Id": "Terraform_created_policy_for_producer_kms_key",
      "Statement": [
          {
              "Sid": "Enable IAM User Permissions",
              "Effect": "Allow",
              "Principal": {
                  "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
              },
              "Action": "kms:*",
              "Resource": "*"
          },
          {
              "Sid": "Allow access for Key Administrators",
              "Effect": "Allow",
              "Principal": {
                  "AWS": "${aws_iam_role.producer_asg_role.arn}"
              },
              "Action": [
                  "kms:Create*",
                  "kms:Describe*",
                  "kms:Enable*",
                  "kms:List*",
                  "kms:Put*",
                  "kms:Update*",
                  "kms:Revoke*",
                  "kms:Disable*",
                  "kms:Get*",
                  "kms:Delete*",
                  "kms:ImportKeyMaterial",
                  "kms:TagResource",
                  "kms:UntagResource",
                  "kms:ScheduleKeyDeletion",
                  "kms:CancelKeyDeletion"
              ],
              "Resource": "*",
              "Condition": {
                  "StringEquals": {
                      "kms:ViaService": "s3.${data.aws_region.current.name}.amazonaws.com"
                  },
                  "Bool": {
                      "kms:GrantIsForAWSResource": "true"
                  }
              }
          },
          {
              "Sid": "Allow use of the key",
              "Effect": "Allow",
              "Principal": {
                  "AWS": "${aws_iam_role.producer_asg_role.arn}"
              },
              "Action": [
                  "kms:Encrypt",
                  "kms:Decrypt",
                  "kms:ReEncrypt*",
                  "kms:GenerateDataKey*",
                  "kms:DescribeKey"
              ],
              "Resource": "*"
          }
      ]
  }
EOF

  tags = {
    Name      = "${var.producer}-kms-key"
    Terraform = true
  }
}
