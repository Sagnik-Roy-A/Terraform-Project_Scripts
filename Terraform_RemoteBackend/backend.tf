terraform {
  backend "s3" {
    bucket = "sagnik-s3-remote-backend"
    region = "ap-south-1"
    key = "sagnikRemoteBackend/terraform.tfstate"
    dynamodb_table = "Dynamo-Backend_Lock"
  }
} 
