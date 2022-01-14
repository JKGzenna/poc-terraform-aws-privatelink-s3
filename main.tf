provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.credentials}"
  profile                 = "default"
}

terraform {
  # It is expected that the bucket already exists
  backend "s3" {
    # a globally unique bucket name
    bucket  = "privatelink-202907271837"
    key     = "privatelinks/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}
