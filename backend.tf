terraform {
  backend "s3" {
    bucket         = "sohail-terraform-state-prod"
    key            = "terraform/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

