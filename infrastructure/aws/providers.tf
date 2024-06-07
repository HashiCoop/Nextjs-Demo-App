terraform {
  required_providers {
    doormat = {
      source  = "doormat.hashicorp.services/hashicorp-security/doormat"
      version = "~> 0.0.0"
    }
  }
}

variable "TFC_WORKSPACE_NAME" {}

data "doormat_aws_credentials" "creds" {
  role_arn = "arn:aws:iam::390101570318:role/${var.TFC_WORKSPACE_NAME}"
}

provider "aws" {
  region     = "us-east-1"
  access_key = data.doormat_aws_credentials.creds.access_key
  secret_key = data.doormat_aws_credentials.creds.secret_key
  token      = data.doormat_aws_credentials.creds.token
}
