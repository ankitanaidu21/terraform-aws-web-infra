variable "aws_region" {
  type        = string
  description = "AWS region to use for resources"
  default     = "us-east-1"
}


##########################
#Networking

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in VPC"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in VPC"
  default     = true
}
variable "vpc_cidr_block" {
  type        = string
  description = "Base CIDR Block for VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnet_count" {
  type        = number
  description = "Number of public subnets to create"
  default     = 2
}

variable "vpc_private_subnet_count" {
  type        = number
  description = "Number of private subnets to create"
  default     = 2
}

variable "vpc_public_subnets_cidr_block" {
  type        = list(string)
  description = "CIDR Block for public subnet 1 in VPC"
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}


variable "map_public_ip_on_launch" {
  type        = bool
  description = "Map a public IP address for subnet instances"
  default     = true
}


variable "vpc_private_subnets_cidr_block" {
  type        = list(string)
  description = "CIDR Block for private subnet 1 in VPC"
  default     = ["10.0.100.0/24", "10.0.200.0/24"]
}

variable "instance_type" {
  type        = string
  description = "AWS instance"
  default     = "t3.micro"
}

#Tags

variable "company" {
  type        = string
  description = "Compnay name for resource tagging"
  default     = "Globomantics"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
}


variable "billing_code" {
  type        = string
  description = "Billing code for resource tagging"
}

