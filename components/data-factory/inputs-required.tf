variable "env" {
  type        = string
  description = "this is the environment variable"
  default     = "stg"
}

variable "builtFrom" {}

variable "storage_account_tier" {
  type        = string
  description = "The storage account tier"
  default     = "Premium"

}

variable "storage_account_replication" {
  type        = string
  description = "The storage account replication type"
  default     = "LRS"

}

variable "storage_account_type" {
  type        = string
  description = "The storage account type"
  default     = "StorageV2"

}

variable "storage_account_name" {
  type        = string
  description = "The storage account name"

}

variable "resource_group_name" {
  default     = "baubais-data-factory-rg-stg"
  description = "The resource group name"

}
