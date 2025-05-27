# aws Launch template

resource "aws_launch_template" "webserver_lt" {
  name_prefix   = "myapp_ec2_launch_templ"
  image_id      = "ami-00c39f71452c08778"
  instance_type = "t2.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.nginx_profile.name
  }
  user_data = filebase64("user_data.sh")

  network_interfaces {
    associate_public_ip_address = false
    #subnet_id                   = aws_subnet.private_subnets[count.index].id
    security_groups = [aws_security_group.asg_sg.id]

  }
  depends_on = [aws_iam_role_policy.allow_s3_all]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Ankita-instance" # Name for the EC2 instances
    }
  }

}


# ASG

resource "aws_autoscaling_group" "web-asg" {
  desired_capacity  = 2
  max_size          = 4
  min_size          = 2
  target_group_arns = [aws_lb_target_group.webserver-tg.arn] # Attach to ALB here

  vpc_zone_identifier = [
    for i in aws_subnet.private_subnets[*] :
    i.id
  ]

  launch_template {
    id      = aws_launch_template.webserver_lt.id
    version = "$Latest"
  }
  health_check_type         = "ELB" # ✅ Use the Target Group's health checks
  health_check_grace_period = 300
}


# aws iam_role
# aws iam_role policy
#aws_iam_instance_profile

# S3 access for instances
resource "aws_iam_role" "allow_nginx_s3" {
  name = "allow_nginx_s3"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = local.common_tags
}

resource "aws_iam_instance_profile" "nginx_profile" {
  name = "nginx_profile"
  role = aws_iam_role.allow_nginx_s3.name

  tags = local.common_tags
}

resource "aws_iam_role_policy" "allow_s3_all" {
  name = "allow_s3_all"
  role = aws_iam_role.allow_nginx_s3.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${local.s3_bucket_name}",
                "arn:aws:s3:::${local.s3_bucket_name}/*"
            ]
    }
  ]
}
EOF

}

