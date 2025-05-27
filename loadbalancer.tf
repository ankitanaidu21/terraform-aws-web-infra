# aws_elb_service_account
data "aws_elb_service_account" "root" {}




# aws_lb
resource "aws_lb" "webserver" {
  name                       = "webserver-web-app-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [for i in aws_subnet.public_subnets : i.id]
  depends_on                 = [aws_internet_gateway.myappigw, aws_s3_bucket_policy.web_bucket]
  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.web_bucket.bucket
    prefix  = "alb-logs"
    enabled = true

  }

}

# aws_lb_target_group
resource "aws_lb_target_group" "webserver-tg" {
  name     = "webserver-web-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myapp.id

}
# aws_lb_listener

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.webserver.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver-tg.arn
  }

  tags = local.common_tags
}



