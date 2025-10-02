terraform {
  backend "s3" {
    bucket               = "terraform-bucket"
    key                  = "terraform.tfstate"
    region               = "us-east-1"
    workspace_key_prefix = "workspaces"

    endpoints = {
      s3 = "http://localhost:4566"
    }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    use_path_style              = true
  }

}
