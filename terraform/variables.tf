variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"
}

variable "aws_account_id" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"
}


variable "snowflake_account" {
  description = "snowflake account"
  type        = string
}

variable "snowflake_username" {
  description = "snowflake username"
  type        = string
}

variable "snowflake_password" {
  description = "snowflake password"
  type        = string
}

variable "snowflake_external_id" {
  description = "snowflake password"
  type        = string
}

