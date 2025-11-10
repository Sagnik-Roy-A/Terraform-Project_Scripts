provider "aws" {
  region = "ap-south-1"
}

module "moduled_aws_instance" {
    source = "./modules/Ec2"
    ami = "ami-02b8269d5e85954ef"
    instance_type = "t2.micro"
}