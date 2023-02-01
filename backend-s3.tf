terraform {
  backend "s3" {
    bucket = "terra-aws-rt-project"
    key    = "terraform/backend"
    region = "us-east-2"
  }
}