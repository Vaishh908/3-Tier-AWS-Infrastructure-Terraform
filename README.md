# 3-Tier Infrastructure Deployment Using Terraform Modules 

# Project Overview

The 3-Tier Infrastructure Deployment Using Terraform Modules project is designed to provision and configure a scalable, secure, and highly available web application infrastructure on Amazon Web Services (AWS) using Terraform.

The architecture is divided into three logical tiers:

Presentation Tier – Public-facing web servers running Nginx.
Application Tier – Private application servers responsible for processing requests and application logic.
Database Tier – A private Amazon RDS database used for persistent data storage.

Terraform modules are used to make the infrastructure reusable, organized, and easy to maintain. The infrastructure includes a custom VPC, public and private subnets across multiple Availability Zones, Internet Gateway, NAT Gateway, route tables, EC2 instances, security groups, and Amazon RDS.

The project demonstrates Infrastructure as Code (IaC), AWS networking, modular Terraform design, security practices, and automated infrastructure provisioning.

---

#  Technology Stack

| Technology            | Purpose                                            |
| --------------------- | -------------------------------------------------- |
| **AWS**               | Cloud infrastructure platform                      |
| **Terraform**         | Infrastructure as Code and resource provisioning   |
| **Amazon VPC**        | Network isolation                                  |
| **Public Subnets**    | Host internet-facing resources                     |
| **Private Subnets**   | Host application and database resources            |
| **Internet Gateway**  | Internet connectivity for public subnets           |
| **NAT Gateway**       | Outbound internet access from private subnets      |
| **Amazon EC2**        | Compute instances for web/application tiers        |
| **Amazon RDS**        | Managed relational database                        |
| **Nginx**             | Web server/reverse proxy                           |
| **Ubuntu Linux**      | Operating system for EC2 instances                 |
| **AWS CLI**           | AWS resource management and verification           |
| **Git/GitHub**        | Source-code and Terraform configuration management |
| **Terraform Modules** | Reusable infrastructure components                 |

---

#  Architectural Diagram


<img width="1024" height="1536" alt="ChatGPT Image Aug 20, 2026, 12_34_35 PM" src="https://github.com/user-attachments/assets/8364c451-79f7-443b-88e2-1e4b758eae54" />

---

# Traffic Flow

```text
User
  |
  v
Internet Gateway
  |
  v
Public Web Server
  |
  v
Private Application Server
  |
  v
Private RDS Database
```
The database is not directly accessible from the internet. Security groups restrict communication between each tier.

---

# Prerequisites

Before implementing the project, ensure that the following requirements are available.

Hardware/Environment
Ubuntu/Linux environment or AWS EC2 instance
Internet connectivity
AWS account
GitHub account
Software

Install and verify:

terraform --version
aws --version
git --version

Optional:

ansible --version
AWS Requirements

The AWS account should have permission to create:

VPC
Subnets
Internet Gateway
NAT Gateway
Route Tables
Security Groups
EC2 instances
RDS database
IAM-related resources if required
AWS Region

The project can be deployed in:

ap-south-1

which represents the Asia Pacific (Mumbai) AWS region.

---

# Installation Steps

## Step 1: Update the System
sudo apt update
sudo apt upgrade -y

---

## Step 2: Install Git
sudo apt install git -y

Verify:

git --version

---

## Step 3: Install AWS CLI

Verify whether AWS CLI is already installed:

aws --version

Configure AWS:

aws configure

Enter the required credentials:

AWS Access Key ID: YOUR_ACCESS_KEY
AWS Secret Access Key: YOUR_SECRET_KEY
Default region name: ap-south-1
Default output format: json

Verify:

aws sts get-caller-identity

---

## Step 4: Install Terraform

Verify:

terraform --version

If Terraform is not installed, install it using the official HashiCorp installation method for Ubuntu.

<img width="1912" height="1024" alt="Screenshot 2026-08-19 144432" src="https://github.com/user-attachments/assets/77695959-9379-403e-a027-cc5d84a0a550" />

---

## Step 5: Clone the Project

git clone <>

Move into the project:

cd 3-tier-terraform-aws

---

## Step 6: Verify the Project Structure

tree

or:

find . -maxdepth 3 -type f

---

# Project Structure


```text
3-tier-terraform-aws/
│
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
│
├── modules/
│   │
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── user_data/
│   │       ├── web.sh
│   │       └── app.sh
│   │
│   └── rds/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── application/
    └── application files
```

---

### Important Files

main.tf

Contains the main Terraform configuration and module calls.

variables.tf

Defines configurable variables such as:

AWS region
VPC CIDR
subnet CIDRs
instance type
database configuration

outputs.tf

Displays useful information after deployment, such as:

VPC ID
subnet IDs
EC2 public IP
RDS endpoint

modules/vpc

Responsible for:

VPC
public subnets
private subnets
Internet Gateway
NAT Gateway
route tables

modules/ec2

Responsible for:

EC2 instances
security groups
user-data configuration
web/application server setup

modules/rds

Responsible for:

RDS subnet group
RDS database
database security group
database configuration


# Implementation Steps

## Step 1: Create the Project Directory

Create a dedicated directory for the Terraform project.

```bash
mkdir 3-tier-terraform-aws
cd 3-tier-terraform-aws
```

Initialize Git:

```bash
git init
```

Create the main Terraform files:

```bash
touch main.tf variables.tf outputs.tf provider.tf terraform.tfvars
```

Create the module directories:

```bash
mkdir -p modules/vpc
mkdir -p modules/ec2/user_data
mkdir -p modules/rds
mkdir -p application
```

Verify:

```bash
tree
```

---

## Step 2: Configure AWS Provider

Create `provider.tf`.

The provider tells Terraform that AWS will be used and specifies the AWS region.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}
```

Define the region in `variables.tf`:

```hcl
variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-south-1"
}
```

---

## Step 3: Configure Terraform Variables

Create the required variables in `variables.tf`.

Example:

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for application subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
```

These variables make the infrastructure configurable instead of hard-coding values throughout the project.

---

# Step 4: Create the VPC Module

Move into the VPC module:

```bash
cd modules/vpc
```

Create:

```bash
touch main.tf variables.tf outputs.tf
```

The VPC module is responsible for creating the complete networking layer.

The following resources are required:

```text
VPC
│
├── Internet Gateway
│
├── Public Subnet AZ-A
├── Public Subnet AZ-B
│
├── Private Application Subnet AZ-A
├── Private Application Subnet AZ-B
│
├── Private Database Subnet AZ-A
└── Private Database Subnet AZ-B
```

---

# Step 5: Create the VPC

Inside `modules/vpc/main.tf`:

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "three-tier-vpc"
  }
}
```

The VPC provides an isolated network for the entire application.

---

# Step 6: Create Availability Zones

The infrastructure should use two Availability Zones for improved availability.

For example:

```text
ap-south-1a
ap-south-1b
```

Terraform can dynamically retrieve available zones:

```hcl
data "aws_availability_zones" "available" {
  state = "available"
}
```

This avoids hard-coding Availability Zone names.

---

# Step 7: Create Public Subnets

Create two public subnets:

```text
Public Subnet AZ-A
10.0.1.0/24

Public Subnet AZ-B
10.0.2.0/24
```

Example:

```hcl
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}
```

Public subnets are used for resources that need inbound internet connectivity.

---

# Step 8: Create Private Application Subnets

Create two private application subnets:

```text
Private App Subnet AZ-A
10.0.11.0/24

Private App Subnet AZ-B
10.0.12.0/24
```

Example:

```hcl
resource "aws_subnet" "private_app" {
  count = length(var.private_app_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-app-subnet-${count.index + 1}"
  }
}
```

These subnets contain the application servers and do not receive public IP addresses.

---

# Step 9: Create Private Database Subnets

Create two database subnets:

```text
Private DB Subnet AZ-A
10.0.21.0/24

Private DB Subnet AZ-B
10.0.22.0/24
```

Example:

```hcl
resource "aws_subnet" "private_db" {
  count = length(var.private_db_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-db-subnet-${count.index + 1}"
  }
}
```

These subnets are dedicated to the database tier.

---

# Step 10: Create the Internet Gateway

Create an Internet Gateway:

```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "three-tier-igw"
  }
}
```

The Internet Gateway provides internet connectivity to resources in public subnets.

---

# Step 11: Create the Public Route Table

Create a route table for the public subnets:

```hcl
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}
```

Associate it with both public subnets.

```hcl
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
```

Traffic now follows:

```text
Public Subnet
      |
      v
Public Route Table
      |
      v
Internet Gateway
      |
      v
Internet
```

---

# Step 12: Create the NAT Gateway

Private application servers may need outbound internet access for:

* Package installation
* Software updates
* Downloading dependencies
* External API access

Create an Elastic IP:

```hcl
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}
```

Create the NAT Gateway inside a public subnet:

```hcl
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "three-tier-nat"
  }

  depends_on = [aws_internet_gateway.main]
}
```

The NAT Gateway allows private instances to initiate outbound connections without exposing them to inbound internet traffic.

---

# Step 13: Create the Private Application Route Table

Create a route table for the application tier:

```hcl
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.main.id
  }

  tags = {
    Name = "private-app-route-table"
  }
}
```

Associate it with the private application subnets:

```hcl
resource "aws_route_table_association" "private_app" {
  count = length(aws_subnet.private_app)

  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app.id
}
```

---

# Step 14: Configure Database Route Table

The database tier should not have direct internet access.

Create a database route table:

```hcl
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-db-route-table"
  }
}
```

Associate the database subnets:

```hcl
resource "aws_route_table_association" "private_db" {
  count = length(aws_subnet.private_db)

  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db.id
}
```

There is intentionally no default route to an Internet Gateway or NAT Gateway for the database tier.

---

# Step 15: Add VPC Module Outputs

Create `modules/vpc/outputs.tf`.

Export the values required by other modules:

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  value = aws_subnet.private_app[*].id
}

output "private_db_subnet_ids" {
  value = aws_subnet.private_db[*].id
}
```

These outputs allow the EC2 and RDS modules to use the network created by the VPC module.

---

# Step 16: Create the EC2 Module

Create the EC2 module:

```bash
cd ../../
cd modules/ec2
```

Create:

```bash
touch main.tf variables.tf outputs.tf
```

The EC2 module will create the compute layer.

The architecture is:

```text
Public Subnets
    |
    +---- Web EC2 / Nginx
    |
    +---- Web EC2 / Nginx

Private App Subnets
    |
    +---- Application EC2
    |
    +---- Application EC2
```

---

# Step 17: Create EC2 Security Groups

The web security group should allow HTTP traffic.

Example:

```hcl
resource "aws_security_group" "web" {
  name        = "three-tier-web-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

For production, replace `YOUR_IP/32` with the administrator's trusted public IP.

---

# Step 18: Create Application Security Group

The application tier should accept traffic only from the web tier.

For example, if the application listens on port `5000`:

```hcl
resource "aws_security_group" "app" {
  name        = "three-tier-app-sg"
  description = "Security group for application servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Application traffic from web tier"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

This prevents arbitrary internet traffic from directly accessing the application server.

---

# Step 19: Create the Web EC2 Instance

Use an Ubuntu AMI and launch the web server in a public subnet.

The EC2 instance should:

* Receive a public IP
* Use the web security group
* Install Nginx
* Start Nginx automatically

Example:

```hcl
resource "aws_instance" "web" {
  count = 2

  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = var.public_subnet_ids[count.index]
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  user_data = file("${path.module}/user_data/web.sh")

  tags = {
    Name = "web-server-${count.index + 1}"
  }
}
```

---

# Step 20: Create the Nginx User-Data Script

Create:

```text
modules/ec2/user_data/web.sh
```

Add:

```bash
#!/bin/bash

apt-get update -y
apt-get install -y nginx

systemctl enable nginx
systemctl start nginx

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>3-Tier AWS Application</title>
</head>
<body>
    <h1>3-Tier AWS Infrastructure</h1>
    <p>Web Server is running successfully.</p>
</body>
</html>
EOF
```

Make the script executable:

```bash
chmod +x modules/ec2/user_data/web.sh
```

---

# Step 21: Create Application EC2 Instances

Application instances are deployed into private subnets.

Example:

```hcl
resource "aws_instance" "app" {
  count = 2

  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id              = var.private_app_subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = file("${path.module}/user_data/app.sh")

  tags = {
    Name = "app-server-${count.index + 1}"
  }
}
```

These instances do not receive public IP addresses.

---

# Step 22: Configure the Application Server

Create:

```text
modules/ec2/user_data/app.sh
```

Example:

```bash
#!/bin/bash

apt-get update -y
apt-get install -y python3 python3-pip

mkdir -p /opt/application

echo "Application Server Running" > /opt/application/index.html
```

If the project has a real backend application, the script can additionally:

* Install Python/Node.js
* Copy application files
* Install dependencies
* Configure environment variables
* Create a systemd service
* Start the application

---

# Step 23: Create the RDS Module

Move into:

```bash
cd ../rds
```

Create:

```bash
touch main.tf variables.tf outputs.tf
```

The RDS module creates the database layer.

Architecture:

```text
Application EC2
       |
       | TCP 3306
       v
RDS Security Group
       |
       v
Amazon RDS
```

---

# Step 24: Create RDS Security Group

The database security group should allow MySQL traffic only from the application security group.

```hcl
resource "aws_security_group" "rds" {
  name        = "three-tier-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from application tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

There should be no rule such as:

```text
3306 from 0.0.0.0/0
```

because that would expose the database to the internet.

---

# Step 25: Create RDS Subnet Group

RDS requires a DB subnet group when using private subnets.

```hcl
resource "aws_db_subnet_group" "main" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = "three-tier-db-subnet-group"
  }
}
```

The DB subnet group contains subnets from multiple Availability Zones.

---

# Step 26: Create the RDS Instance

Example:

```hcl
resource "aws_db_instance" "main" {
  identifier = "three-tier-database"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 50

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible    = false
  skip_final_snapshot    = true

  backup_retention_period = 7

  tags = {
    Name = "three-tier-rds"
  }
}
```

For a production environment, use a secure secret-management mechanism rather than committing database passwords to Git.

---

# Step 27: Create the Main Terraform Configuration

Return to the project root:

```bash
cd ../..
```

The root `main.tf` calls the modules.

Example:

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr                  = var.vpc_cidr
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  private_db_subnet_cidrs   = var.private_db_subnet_cidrs
}

module "ec2" {
  source = "./modules/ec2"

  vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
}

module "rds" {
  source = "./modules/rds"

  vpc_id                 = module.vpc.vpc_id
  private_db_subnet_ids  = module.vpc.private_db_subnet_ids
  app_security_group_id  = module.ec2.app_security_group_id
}
```

The root module therefore controls the overall architecture while individual modules manage specific infrastructure components.

---

# Step 28: Configure Terraform Variables

Create `terraform.tfvars`.

Example:

```hcl
aws_region    = "ap-south-1"
vpc_cidr      = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_app_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

private_db_subnet_cidrs = [
  "10.0.21.0/24",
  "10.0.22.0/24"
]

instance_type = "t3.micro"
```

Do not commit passwords or access keys to GitHub.

Add sensitive files to `.gitignore`:

```text
terraform.tfstate
terraform.tfstate.*
.terraform/
*.tfvars
*.tfvars.json
*.pem
```

---

# Step 29: Initialize Terraform

Run from the project root:

```bash
terraform init
```

Terraform downloads the AWS provider and initializes all modules.

Expected output contains:

```text
Terraform has been successfully initialized!
```

---

# Step 30: Format the Configuration

Run:

```bash
terraform fmt -recursive
```

This automatically formats all Terraform files.

---

# Step 31: Validate the Configuration

Run:

```bash
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

If an error occurs, fix the configuration before continuing.

---

# Step 32: Generate the Terraform Plan

Run:

```bash
terraform plan
```

Review the resources Terraform intends to create.

You should see resources corresponding to:

```text
VPC
Subnets
Internet Gateway
NAT Gateway
Route Tables
Security Groups
EC2 Instances
RDS
DB Subnet Group
```

Do not proceed if the plan contains unexpected resource deletion or modification.

---

# Step 33: Deploy the Infrastructure

Run:

```bash
terraform apply
```

Terraform displays the execution plan.

Enter:

```text
yes
```

Terraform starts creating the resources.

The NAT Gateway and RDS resources may take several minutes to become available.

---

# Step 34: Check Terraform State

After deployment:

```bash
terraform show
```

You can also list Terraform-managed resources:

```bash
terraform state list
```

Example:

```text
module.vpc.aws_vpc.main
module.vpc.aws_subnet.public
module.vpc.aws_subnet.private_app
module.vpc.aws_subnet.private_db
module.ec2.aws_instance.web
module.ec2.aws_instance.app
module.rds.aws_db_instance.main
```

---

# Step 35: Check Terraform Outputs

Run:

```bash
terraform output
```

Useful outputs include:

```text
VPC ID
Public Subnet IDs
Private Application Subnet IDs
Private Database Subnet IDs
Web Server Public IP
RDS Endpoint
```

---

# Step 36: Verify the VPC

Using AWS CLI:

```bash
aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=three-tier-vpc"
```

Verify that the VPC exists with the correct CIDR:

```text
10.0.0.0/16
```

---

# Step 37: Verify Subnets

Run:

```bash
aws ec2 describe-subnets
```

Verify that there are separate:

```text
Public Subnet AZ-A
Public Subnet AZ-B

Private App Subnet AZ-A
Private App Subnet AZ-B

Private DB Subnet AZ-A
Private DB Subnet AZ-B
```

---

# Step 38: Verify Internet Gateway and NAT Gateway

Check Internet Gateway:

```bash
aws ec2 describe-internet-gateways
```

Check NAT Gateway:

```bash
aws ec2 describe-nat-gateways
```

The NAT Gateway should have a state similar to:

```text
available
```

---

# Step 39: Verify EC2 Instances

Run:

```bash
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PrivateIpAddress,PublicIpAddress]'
```

Verify that the EC2 instances are:

```text
running
```

The web servers should have public IP addresses.

The private application servers should not have public IP addresses.

---

# Step 40: Connect to the Web Server

Use the public IP obtained from Terraform:

```bash
ssh -i <key.pem> ubuntu@<WEB_PUBLIC_IP>
```

Check Nginx:

```bash
sudo systemctl status nginx --no-pager
```

Expected:

```text
Active: active (running)
```

Test:

```bash
curl http://localhost
```

---

# Step 41: Test Web Server from Your Computer

Open:

```text
http://<WEB_PUBLIC_IP>
```

You should see:

```text
3-Tier AWS Infrastructure
Web Server is running successfully.
```

This verifies the public web tier.

---

# Step 42: Verify Private Application Server

The application server should not be directly accessible from the internet.

From an authorized host within the VPC, test its private IP:

```bash
curl http://<PRIVATE_APP_IP>:5000
```

If the backend application is configured correctly, it should return the expected application response.

---

# Step 43: Verify RDS

Check the RDS instance:

```bash
aws rds describe-db-instances \
  --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address,PubliclyAccessible]'
```

The expected database state is:

```text
available
```

The public accessibility value should be:

```text
False
```

---

# Step 44: Verify Database Connectivity

From the application server, test the RDS endpoint.

For MySQL:

```bash
mysql -h <RDS_ENDPOINT> -P 3306 -u <USERNAME> -p
```

Enter the database password when prompted.

Successful connection confirms:

```text
Application Tier
       |
       | TCP 3306
       v
RDS Database
```

---

# Step 45: Verify Security Rules

Check security groups in AWS.

The intended communication should be:

```text
Internet
   |
   | HTTP/HTTPS
   v
Web Security Group
   |
   | Application Port
   v
Application Security Group
   |
   | TCP 3306
   v
RDS Security Group
```

The RDS security group should accept port `3306` only from the application security group.

---

# Step 46: Test the Complete Application Flow

Perform an end-to-end test:

```text
Client
  |
  v
Public IP
  |
  v
Nginx Web Server
  |
  v
Private Application Server
  |
  v
Amazon RDS
```

Verify each layer independently before testing the complete flow.

---

# Step 47: Verify Terraform Idempotency

Run:

```bash
terraform plan
```

after the infrastructure has already been deployed.

Ideally Terraform should report that there are no changes required.

This demonstrates that the Terraform configuration correctly represents the deployed infrastructure.

---

# Step 48: Capture Screenshots for Project Documentation

For the project report or GitHub README, capture screenshots of:

1. Terraform project structure
2. `terraform init`
3. `terraform validate`
4. `terraform plan`
5. Successful `terraform apply`
6. AWS VPC
7. Public and private subnets
8. Internet Gateway
9. NAT Gateway
10. Route tables
11. Security groups
12. Running EC2 instances
13. Nginx status
14. Nginx webpage
15. RDS instance
16. RDS connectivity
17. `terraform output`
18. Final architecture


