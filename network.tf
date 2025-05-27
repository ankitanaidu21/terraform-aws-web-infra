
##################################################################################
# DATA
##################################################################################


data "aws_availability_zones" "available" {
  state = "available"
}

##########################################################################
# NETWORKING
###########################################################################

#VPC

resource "aws_vpc" "myapp" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  # enable_dns_support   = var.enable_dns_support
  tags = {
    Name = "myapp_vpc"
  }
}

#Subnets

resource "aws_subnet" "public_subnets" {
  count                   = var.vpc_public_subnet_count
  vpc_id                  = aws_vpc.myapp.id
  cidr_block              = var.vpc_public_subnets_cidr_block[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = local.common_tags
}


resource "aws_subnet" "private_subnets" {
  count                   = var.vpc_private_subnet_count
  vpc_id                  = aws_vpc.myapp.id
  cidr_block              = var.vpc_private_subnets_cidr_block[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = local.common_tags

}


#Internet Gateway

resource "aws_internet_gateway" "myappigw" {
  vpc_id = aws_vpc.myapp.id
  tags = {
    Name = "myapp-igw"
  }
}


#Routing

resource "aws_route_table" "myapp_publicrt" {
  vpc_id = aws_vpc.myapp.id
  tags = {
    Name = "myapp-public_rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myappigw.id
  }
}

resource "aws_route_table_association" "app_public_subnets" {
  count          = var.vpc_public_subnet_count
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.myapp_publicrt.id
}


#Elastic IP

resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.myappigw]
  domain     = "vpc"
  tags = {
    Name = "myapp-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "myappnatgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    Name = "myapp-natgw"
  }
  depends_on = [aws_internet_gateway.myappigw]

}


resource "aws_route_table" "myapp_privatert" {
  vpc_id = aws_vpc.myapp.id
  tags = {
    Name = "myapp-private_rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.myappnatgw.id
  }
}
resource "aws_route_table_association" "app_private_subnets" {
  count          = var.vpc_private_subnet_count
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.myapp_privatert.id
}

##########################################################################
# Security Groups
###########################################################################
##################################################################################
# Security Groups
##################################################################################

#Custom AMI SG

resource "aws_security_group" "WebServer" {
  name   = "custom_ami_webserver_sg"
  vpc_id = aws_vpc.myapp.id

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from anywhere 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


#ALB security group

resource "aws_security_group" "alb_sg" {
  name   = "alb_sg"
  vpc_id = aws_vpc.myapp.id

  # HTTP access from anywhere
  ingress {
    description      = "Allow http request from anywhere"
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow https request from anywhere"
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#ASG security group

resource "aws_security_group" "asg_sg" {
  name   = "asg_sg"
  vpc_id = aws_vpc.myapp.id

  # HTTP access from anywhere
  ingress {
    description     = "Allow http request from Load Balancer"
    protocol        = "tcp"
    from_port       = 80 # range of
    to_port         = 80 # port numbers
    security_groups = [aws_security_group.alb_sg.id]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

