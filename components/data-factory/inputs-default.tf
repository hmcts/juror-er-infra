

variable "location" {
  default     = "UK South"
  description = "Location of the resource"

}

variable "resource_group_name" {
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










