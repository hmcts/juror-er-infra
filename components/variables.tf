variable "env" {
  type        = string
  description = "this is the environment variable"
  default     = "stg"

}

variable "location" {
  default     = "UK South"
  description = "Location of the resource"

}

variable "resource_group_name" {
  default     = "rg-juror-er"
  description = "The resource group name"

}

variable "storage_account_name" {
  default     = "stojurorer"
  description = "The storage account name"

}
variable "product" {
  description = "The product name or identifier"
  type        = string
  default     = "sds-platform"
}
variable "builtFrom" {
  description = "Information about the build source or version"
  type        = string
  default     = "https://github.com/hmcts/juror-er-infra"
}










