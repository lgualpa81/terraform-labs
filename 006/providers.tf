terraform {
  required_version = ">= 1.6.4"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }

  }

  backend "s3" {
    bucket               = "terraform-bucket"
    key                  = "terraform.tfstate"
    region               = "us-east-1"
    workspace_key_prefix = "workspaces"
    access_key           = "fake-test"
    secret_key           = "fake-test"

    endpoints = {
      s3 = "http://localhost:4566"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}


