# Data tier - S3

data "aws_iam_policy_document" "bucket_policy_document" {
  statement {
    sid       = "1"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_fqdn}{$var.iam_policy_resources_path}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.identity.iam_arn}"]
    }
  }

  statement {
    sid       = "2"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.bucket_fqdn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.identity.iam_arn}"]
    }
  }
}

resource "aws_iam_policy" "bucket_policy" {
  name_prefix = "${var.short_name}"
  path        = "${var.iam_policy_path}"
  policy      = "${data.aws_iam_policy_document.bucket_policy_document.json}"
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.bucket_fqdn}"
  acl           = "${var.bucket_acl}"
  region        = "${data.aws_region.region.name}"
  force_destroy = "${var.bucket_force_destroy}"
  policy        = "${data.aws_iam_policy_document.bucket_policy_document.json}"

  cors_rule {
    allowed_headers = "${var.bucket_cors_allowed_headers}"
    allowed_methods = "${var.bucket_cors_allowed_methods}"
    allowed_origins = "${var.bucket_cors_allowed_origins}"
    expose_headers  = "${var.bucket_cors_expose_headers}"
    max_age_seconds = "${var.bucket_cors_max_age_seconds}"
  }
}


# outputs from data tier

output "S3 bucket domain name" {
  value = "${aws_s3_bucket.bucket.bucket_domain_name}"
}
