terraform {
  cloud {
    organization = "cherry-space"
    hostname = "app.terraform.io"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {}