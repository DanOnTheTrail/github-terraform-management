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

  branch_config = { for r in flatten(
    values(
      { for repo in local.repos : repo.name =>
        [for rule in repo.branch_protection_rules :
    merge(rule, { repo = repo.name })] if lookup(repo, "branch_protection_rules", {}) != {} })) :
  "${r.repo}-${r.pattern}" => r }

  repo_write_access = values({ for repo in local.repos : 
    repo.name => { for team in lookup(repo, "write_access_teams", []) :
      "${repo.name}-${team}" => { repo = repo.name, team = team } } })[0]
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

resource "github_branch_protection" "managed_branch_protection" {
  for_each = local.branch_config

  repository_id = github_repository.managed_repos[each.value.repo].name
  pattern    = each.value.pattern
  enforce_admins = each.value.enforce_admins
  require_signed_commits = each.value.require_signed_commits
  required_linear_history = each.value.required_linear_history
  require_conversation_resolution = each.value.require_conversation_resolution
  allows_deletions = each.value.allows_deletions
  allows_force_pushes = each.value.allows_force_pushes
  required_pull_request_reviews {
    required_approving_review_count = each.value.required_pull_request_reviews.required_approving_review_count
    dismiss_stale_reviews = each.value.required_pull_request_reviews.dismiss_stale_reviews
    require_code_owner_reviews = each.value.required_pull_request_reviews.require_code_owner_reviews
  }
  required_status_checks {
    strict = each.value.required_status_checks.strict
    contexts = each.value.required_status_checks.contexts
  }
}

resource "github_team_repository" "repo_manged_write_access" {
  for_each = local.repo_write_access

  team_id    = github_team.managed_teams[each.value.team].id
  repository = each.value.repo
  permission = "push"
}
