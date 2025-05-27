# Terraform AWS Web Infrastructure

This repository contains Terraform code to provision a highly available web application infrastructure on AWS using a **basic, single-file structure** (no modules). The setup includes:

> 🧾 **Note**: This project is intentionally kept basic. It does **not** use modules or advanced structuring yet.

- VPC with public and private subnets
- Internet Gateway (IGW) and NAT Gateway
- Auto Scaling Group (ASG) to deploy Amazon Linux EC2 instances
- Application Load Balancer (ALB)
- Static website hosting via Amazon S3
- Access logging delivered to S3 using IAM roles and policies

---

## 📁 Project Structure
terraform-aws-web-infra/
├── main.tf                  # All Terraform configuration in one file
├── variables.tf             # Input variables
├── outputs.tf               # Output values
├── provider.tf              # Provider and backend configuration
├── terraform.tfvars         # Variable definitions (excluded from version control)
└── README.me

---

## 🛠️ Features Implemented

### 1. **Networking**
- A custom VPC with 2 public and 2 private subnets across two AZs
- Internet Gateway for public subnets
- NAT Gateway for outbound access from private subnets

### 2. **Compute & Auto Scaling**
- Auto Scaling Group launches Amazon Linux 2 instances
- User data script installs Apache and PHP
- Instances deployed in private subnets for better security

### 3. **Load Balancer**
- Application Load Balancer (ALB) distributes incoming HTTP traffic
- DNS name of ALB outputted for direct browser access

### 4. **S3 Static Web Hosting**
- Hosts a static web page using S3 static website hosting
- Bucket policy configured for public read access (optional)
- The static page includes an image or link that, when clicked, redirects the user to the actual web application served behind the Application Load Balancer

### 5. **Logging**
- ALB access logs are stored in a dedicated S3 bucket
- IAM role and policy set up for log delivery

---

## 🚀 Getting Started

### 1. Clone the Repository
git clone https://github.com/your-username/terraform-aws-web-infra.git
cd terraform-aws-web-infra

### 2. Initialize Terraform

terraform init


### 3. Plan the Deployment

terraform plan


### 4. Apply the Configuration

terraform apply


---

## 🔍 Accessing the Web Application
- Open the static website hosted in S3 using the S3 website endpoint
- Click the image or link on the page to load the actual web application served via the ALB
- Alternatively, go to the AWS EC2 console > Load Balancers > select `Web-ALB` and use the DNS name directly in your browser

---

## 🔗 Reference
This infrastructure and user data script were inspired by the AWS practice workshop. While the AWS guide demonstrates **manual deployment** of infrastructure, this project showcases how to achieve the same setup using **Infrastructure as Code (IaC)** with **Terraform**:
[https://catalog.us-east-1.prod.workshops.aws/workshops/869a0a06-1f98-4e19-b5ac-cbb1abdfc041/en-US/advanced-modules-cost-monitoring-observability/introduction-to-cost-management/step-4](https://catalog.us-east-1.prod.workshops.aws/workshops/869a0a06-1f98-4e19-b5ac-cbb1abdfc041/en-US/advanced-modules-cost-monitoring-observability/introduction-to-cost-management/step-4)

---

## 📦 Requirements
- Terraform >= 1.0
- AWS CLI configured
- AWS account with appropriate IAM permissions

---

## 🔐 Security Notes
- Sensitive files like `terraform.tfvars` should be excluded from version control
- Use S3 backend and state locking for team collaboration (e.g., S3 + DynamoDB) — optional

---

