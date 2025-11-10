provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "Ec2_instance_V1" {
    ami = var.ami_value
    instance_type = var.instance_value
}

