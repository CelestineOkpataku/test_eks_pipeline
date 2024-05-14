terraform {
  backend "s3" {
    bucket         = "celestine-okpataku-remote-backend"
    key            = "okpataku/comcast-assessment/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "dynamodb-state-locking"

  }
}