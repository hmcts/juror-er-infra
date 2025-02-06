locals {
  is_prod     = length(regexall(".*(prod).*", var.env)) > 0
  admin_group = local.is_prod ? "DTS Platform Operations SC" : "DTS Platform Operations"
}

data "azuread_group" "admin_group" {
  display_name     = local.admin_group
  security_enabled = true
}
