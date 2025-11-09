terraform {
    required_version = ">= 1.0.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

variable "region" {
    type    = string
    default = "us-east-1"
}

variable "instance_type" {
    type    = string
    default = "t3.micro"
}

variable "key_name" {
    type    = string
    default = null
    description = "Optional existing EC2 key pair name in the selected region. Leave null to create instance without SSH key."
}

variable "allowed_ssh_cidr" {
    type    = string
    default = "0.0.0.0/0"
}

provider "aws" {
    region = var.region
}

data "aws_ami" "amazon_linux" {
    most_recent = true
    owners      = ["amazon"]
    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = { Name = "tf-vpc" }
}

resource "aws_subnet" "public" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
    tags = { Name = "tf-public-subnet" }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags   = { Name = "tf-igw" }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = { Name = "tf-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "sg" {
    name        = "tf-ec2-sg"
    description = "Allow SSH and HTTP"
    vpc_id      = aws_vpc.main.id

    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.allowed_ssh_cidr]
    }

    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "tf-ec2-sg" }
}

resource "aws_instance" "web" {
    ami                     = data.aws_ami.amazon_linux.id
    instance_type           = var.instance_type
    subnet_id               = aws_subnet.public.id
    vpc_security_group_ids  = [aws_security_group.sg.id]
    key_name                = var.key_name

    user_data = <<-EOF
                            #!/bin/bash
                            yum update -y
                            yum install -y httpd
                            systemctl enable --now httpd
                            echo "Hello from Terraform" > /var/www/html/index.html
                            EOF

    tags = { Name = "tf-ec2-instance" }
}

output "instance_id" {
    value = aws_instance.web.id
}

output "public_ip" {
    value = aws_instance.web.public_ip
}

output "public_dns" {
    value = aws_instance.web.public_dns
}