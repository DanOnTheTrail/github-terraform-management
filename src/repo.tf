resource "github_repository" "example" {
  name        = "example"
  description = "My awesome web page"

  visibility = "private"
}