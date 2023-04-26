terraform {
  cloud {
    organization = "cherry-spaces"

    workspaces {
      name = "github-terraform-management"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {}