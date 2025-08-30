# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.10.0"
    }
  }
}

# AWS provider configuration with region specification
provider "aws"{                           # aws provider block
  region = "ap-south-1"                  # Mumbai region
  
}