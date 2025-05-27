# aws s3 bucket
resource "aws_s3_bucket" "web_bucket" {
  bucket        = local.s3_bucket_name
  force_destroy = true


  tags = local.common_tags
}

resource "aws_s3_bucket_ownership_controls" "web_bucket_ownership" {
  bucket = aws_s3_bucket.web_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "web_bucket" {
  bucket = aws_s3_bucket.web_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.web_bucket_ownership,
    aws_s3_bucket_public_access_block.web_bucket,
  ]

  bucket = aws_s3_bucket.web_bucket.id
  acl    = "public-read"
}

# aws s3 bucket policy
resource "aws_s3_bucket_policy" "web_bucket" {
  bucket = aws_s3_bucket.web_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.root.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}"
    }
  ]
}
    POLICY
}



# aws s3 object

/*resource "aws_s3_object" "website" {
  bucket = aws_s3_bucket.web_bucket.id
  key    = "index.html"
  content = data.template_file.html_file.rendered
    content_type = "text/html"

  tags = local.common_tags

}*/

resource "aws_s3_object" "website" {
  bucket       = aws_s3_bucket.web_bucket.id
  key          = "index.html"
  content      = local.html_template
  content_type = "text/html"
  acl          = "public-read"
  tags         = local.common_tags
}


resource "aws_s3_object" "graphic" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "aws.png"
  source = "./aws.png"

  tags = local.common_tags

}

/*resource "aws_s3_object" "website_content" {
  for_each = local.website_content
  bucket   = aws_s3_bucket.web_bucket.bucket
  key      = each.value
  source   = "${path.root}/${each.value}"

  tags = local.common_tags

}*/
resource "aws_s3_object" "error_page" {
  bucket       = aws_s3_bucket.web_bucket.id
  key          = "error.html"
  source       = "./error.html"
  content_type = "text/html"
  tags         = local.common_tags
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.web_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }


}
