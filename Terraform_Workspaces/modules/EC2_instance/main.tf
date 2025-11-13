provider "aws" {
    region = "ap-south-1"
}

variable "ami" {
  description = "This is AMI for the instance"
}

variable "instance_type" {
  description = "This is the instance type, for example: t2.micro"
}

resource "aws_instance" "ec2_instance" {
    ami = var.ami
    instance_type = var.instance_type
}