locals {
  common_tags = {
    company      = var.company
    project      = "${var.company}-${var.project}"
    billing_code = var.billing_code
  }

  s3_bucket_name = "immersion-web-${random_integer.s3.result}"

  html_template = templatefile("./template.html",
    {
      bucket_name  = aws_s3_bucket.web_bucket.bucket
      region       = var.aws_region
      object_key   = aws_s3_object.graphic.key
      alb_dns_name = aws_lb.webserver.dns_name
  })

}

resource "random_integer" "s3" {
  min = 10000
  max = 99999
}
