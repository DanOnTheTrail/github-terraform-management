resource "github_repository" "example" {
  name        = "example"
  description = "My awesome web page"

  visibility = "private"
}

locals {
  repos_config = yamldecode(file("${path.module}/../config/repos.yml"))
}

resource "github_repository" "managed_repos" {
  for_each = toset(local.repos_config.repos)

  name        = each.value
  description = "foo"
  visibility  = "private"
}