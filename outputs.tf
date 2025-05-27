output "website_endpoint" {
  value       = "http://${aws_s3_bucket_website_configuration.example.website_endpoint}"
  description = "Static website hosting"

}
