locals {
    # This generates a string formated for a json policy document resource list for the vpc endpoint
    s3_buckets = "${join("\",\"", list(
                     "arn:aws:s3:::${var.producer_s3_bucket_name}",
                     "arn:aws:s3:::${var.producer_s3_bucket_name}/*")
               )}"
}
