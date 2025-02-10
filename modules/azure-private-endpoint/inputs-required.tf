variable "name" {
  description = "The name of the private endpoint"
  type        = string
}

variable "resource_group" {
  description = "The name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to attach the private endpoint to."
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to resources."
  type        = map(string)
}

variable "resource_name" {
  description = "THe name of the resouce to connect to."
  type        = string
}

variable "resource_id" {
  description = "The ID of the resource to connect to."
  type        = string
}

variable "subresource_name" {
  description = "The name of the subresource to connect to. e.g. 'vault' for a key vault."
  type        = string
}
