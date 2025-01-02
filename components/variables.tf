variable "env" {
  type        = string
  description = "this is the environment variable"
}

variable "location" {
  default = "UK South"

}

variable "resource_group_name" {
  default = "rg-juror-er"

}

variable "storage_account_name" {
  default = "stojurorer"

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










