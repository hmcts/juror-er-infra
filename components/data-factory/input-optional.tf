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

variable "product" {
  type    = string
  default = "baubais"
}

variable "containers" {
  description = "List of containers with their access types"
  type = list(object({
    name        = string
    access_type = string
  }))
  default = [
    {
      name        = "data"
      access_type = "private"
    }
  ]
}

variable "location" {
  default     = "UK South"
  description = "Location of the resource"
}

variable "enable_synapse_sql_pool" {
  description = "Enable Synapse SQL Pool"
  type        = bool
  default     = true
}
variable "enable_synapse_spark_pool" {
  description = "Enable Synapse Spark Pool"
  type        = bool
  default     = true
}

variable "github_main_branch" {
  description = "Main branch of the GitHub repository"
  type        = string
  default     = "main"

}

variable "github_repository_name" {
  description = "Name of the GitHub repository"
  type        = string
  default     = "juror-er-infra"
}
variable "github_root_folder" {
  description = "Root folder of the GitHub repository"
  type        = string
  default     = "/synapse"

}
