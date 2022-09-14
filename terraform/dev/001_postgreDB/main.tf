locals {
  env     = "dev"
  region  = "us-west-1"
}

terraform {
  backend "s3" {
    bucket = "aai-terraform-state-do-not-delete-dev"
    key    = "postgreDB.tfstate"
    region = "us-west-1"

    dynamodb_table = "aai-terraform-lock-dev"
    encrypt        = true
  }
}

provider "aws" {
  region  = local.region
}


module "postgreDB" {
  source = "../../templates/postgreDB"
  env    = local.env
}
