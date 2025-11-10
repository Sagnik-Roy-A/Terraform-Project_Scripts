provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "Ec2_Remote" {
  ami = "ami-02b8269d5e85954ef"
  instance_type = "t2.micro"
}

resource "aws_s3_bucket" "S3_RemoteBucket" {
  bucket = "sagnik-s3-remote-backend"
}

resource "aws_dynamodb_table" "Dynamo-Backend_Lock" {
  name             = "terraform-lock"
  hash_key         = "LOCKID"
  billing_mode     = "PAY_PER_REQUEST"


  attribute {
    name = "LOCKID"
    type = "S"
  }
}