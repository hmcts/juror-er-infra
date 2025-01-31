variable "github_configuration" {
  description = "Map of GitHub configuration settings for the Azure Data Factory."
  type = map(object({
    branch_name        = string
    git_url            = string
    repository_name    = string
    root_folder        = string
    publishing_enabled = bool
  }))
  default = {}
}