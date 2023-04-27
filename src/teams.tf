locals {
    teams = {
        for team in yamldecode(file("${path.module}/../config/teams.yml")) :
        team.name => team
    }

    team_members = values({ for team in local.teams : 
        team.name => { for member in team.members : 
            "${team.name}-${member}" => {team = team.name, member =  member }  } })[0]
}

resource "github_team" "managed_teams" {
    for_each = local.teams
    
    name        = each.value.name
    description = each.value.description
}

resource "github_team_membership" "managed_team_members" {
    for_each = local.team_members

    team_id  = github_team.managed_teams[each.value.team].id
    username = each.value.member
    role     = "member"
}