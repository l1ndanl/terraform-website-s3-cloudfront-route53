output "redirect_cdn_hostname" {
  value = "${aws_cloudfront_distribution.redirect_cdn.domain_name}"
}

output "redirect_cdn_zone_id" {
  value = "${aws_cloudfront_distribution.redirect_cdn.hosted_zone_id}"
}
