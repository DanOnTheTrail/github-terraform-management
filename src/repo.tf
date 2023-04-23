resource "github_repository" "example" {
  name        = "example"
  description = "My awesome web page"

  visibility = "private"
}

locals {
  repos = {
    for repo in yamldecode(file("${path.module}/../config/repos.yml")).repos :
    repo.name => repo
  }
}

resource "github_repository" "managed_repos" {
  for_each = local.repos

  name                        = each.value.name
  description                 = each.value.description
  visibility                  = each.value.visibility
  allow_auto_merge            = each.value.allow_auto_merge
  allow_merge_commit          = each.value.allow_merge_commit
  allow_rebase_merge          = each.value.allow_rebase_merge
  allow_squash_merge          = each.value.allow_squash_merge
  delete_branch_on_merge      = each.value.delete_branch_on_merge
  archived                    = each.value.archived
  squash_merge_commit_message = each.value.squash_merge_commit_message
  squash_merge_commit_title   = each.value.squash_merge_commit_title
  allow_update_branch         = each.value.allow_update_branch

  vulnerability_alerts = true
  archive_on_destroy   = true
  has_discussions      = false
  has_issues           = false
  has_projects         = false
  has_wiki             = false
}