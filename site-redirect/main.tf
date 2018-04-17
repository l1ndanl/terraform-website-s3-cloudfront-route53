################################################################################################################
## Creates a setup to serve a static website from an AWS S3 bucket, with a Cloudfront CDN and
## certificates from AWS Certificate Manager.
##
## Bucket name restrictions:
##    http://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html
## Duplicate Content Penalty protection:
##    Description: https://support.google.com/webmasters/answer/66359?hl=en
##    Solution: http://tuts.emrealadag.com/post/cloudfront-cdn-for-s3-static-web-hosting/
##        Section: Restricting S3 access to Cloudfront
## Deploy remark:
##    Do not push files to the S3 bucket with an ACL giving public READ access, e.g s3-sync --acl-public
##
## 2016-05-16
##    AWS Certificate Manager supports multiple regions. To use CloudFront with ACM certificates, the
##    certificates must be requested in region us-east-1
################################################################################################################

################################################################################################################
## Configure the bucket and static website hosting
################################################################################################################
data "template_file" "redirect_bucket_policy" {
  template = "${file("${path.module}/website_redirect_bucket_policy.json")}"

  vars {
    bucket = "${var.domain}"
    iam_arn = "${aws_cloudfront_origin_access_identity.orig_access_ident.iam_arn}"
  }
}

resource "aws_s3_bucket" "redirect_bucket" {
  bucket   = "${var.domain}"
  policy   = "${data.template_file.redirect_bucket_policy.rendered}"

  website {
    redirect_all_requests_to = "https://${var.target}"
  }

  //  logging {
  //    target_bucket = "${var.log_bucket}"
  //    target_prefix = "${var.log_bucket_prefix}"
  //  }

  tags = "${merge("${var.tags}",map("Name", "${var.project}-${var.environment}-${replace("${var.domain}","*","star")}", "Environment", "${var.environment}", "Project", "${var.project}"))}"
}

################################################################################################################
## Create a Cloudfront distribution for the redirect website
################################################################################################################
resource "aws_cloudfront_origin_access_identity" "orig_access_ident" {
  comment = "S3 ${var.domain} CloudFront Origin Access Identity"
}

resource "aws_cloudfront_distribution" "redirect_cdn" {
  enabled      = true
  price_class  = "${var.price_class}"
  http_version = "http2"

  "origin" {
    origin_id   = "S3-origin-${aws_s3_bucket.redirect_bucket.id}"
    domain_name = "${aws_s3_bucket.redirect_bucket.bucket_domain_name}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.orig_access_ident.cloudfront_access_identity_path}"
    }
  }

  default_root_object = "index.html"

  "default_cache_behavior" {
    allowed_methods = ["GET", "HEAD", "DELETE", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    "forwarded_values" {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl          = "0"
    default_ttl      = "300"                                              //3600
    max_ttl          = "1200"                                             //86400
    target_origin_id = "S3-origin-${aws_s3_bucket.redirect_bucket.id}"

    // This redirects any HTTP request to HTTPS. Security first!
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  "restrictions" {
    "geo_restriction" {
      restriction_type = "none"
    }
  }

  "viewer_certificate" {
    acm_certificate_arn      = "${var.acm-certificate-arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  aliases = ["${var.domain}"]

  tags = "${merge("${var.tags}",map("Name", "${var.project}-${var.environment}-${replace("${var.domain}","*","star")}", "Environment", "${var.environment}", "Project", "${var.project}"))}"

}
