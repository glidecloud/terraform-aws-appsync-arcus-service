terraform {
  backend "s3" {
    key            = "lower-dev-users-documents-appsync-api"
    bucket         = "gh-wright-terraform-state"
    dynamodb_table = "gh-wright-terraform-state-lock"
    region         = "us-east-2"
    encrypt        = true
  }

  required_version = "~> 0.12"

  required_providers {
    aws = "~> 3.24.1"
  }
}

provider "aws" {
  profile = "gracehill"
  region  = "us-east-2"
}

locals {
  request_template_path  = "${path.module}/resources/elixirServiceRequestTemplate.tpl"
  response_template_path = "${path.module}/resources/elixirServiceResponseTemplate.tpl"
  arcus_api_path         = "/documents/api/v1"
}

