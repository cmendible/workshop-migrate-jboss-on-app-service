# Resource Group Name
variable "resource_group_name" {
  default = "rg-eap"
}

# Location
variable "location" {
  default = "northeurope"
}

# postgreSQL name
variable "postgresql_name" {
  default = "psqleap"
}

# Function name
variable "app_service_name" {
  default = "weblogic-to-eap"
}