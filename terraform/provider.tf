terraform {
  required_providers {
    snowflake = {
      source = "snowflake-labs/snowflake"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "snowflake" {
  account     = var.snowflake_account
  username    = var.snowflake_username
  password    = var.snowflake_password
}

provider "aws" {
  region      = var.aws_region
  access_key  = var.aws_access_key
  secret_key  = var.aws_secret_key
}