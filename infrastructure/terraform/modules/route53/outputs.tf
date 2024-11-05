output "certificate_arn" {
  value = aws_acm_certificate_validation.api.certificate_arn
}

output "domain_name" {
  description = "Full domain name for the API"
  value       = "${var.project}-${var.env}.${data.aws_route53_zone.main.name}"
}

output "zone_id" {
  description = "Route53 zone ID"
  value       = data.aws_route53_zone.main.zone_id
}

