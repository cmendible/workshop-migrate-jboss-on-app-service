resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_postgresql_server" "server" {
  name                = var.postgresql_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  sku_name = "GP_Gen5_4"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login              = "azureadmin"
  administrator_login_password     = random_password.password.result
  version                          = "11"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"

  threat_detection_policy {
    disabled_alerts      = []
    email_account_admins = false
    email_addresses      = []
    enabled              = true
    retention_days       = 0
  }
}

resource "azurerm_postgresql_database" "db" {
  name                = "monolith"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "host" {
  name                = "host"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Create the Azure Function plan (Elastic Premium) 
resource "azurerm_service_plan" "plan" {
  name                = "asp-${var.app_service_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "P1v3"
}

resource "azurerm_linux_web_app" "eap" {
  name                                           = var.app_service_name
  resource_group_name                            = azurerm_resource_group.rg.name
  location                                       = azurerm_service_plan.plan.location
  service_plan_id                                = azurerm_service_plan.plan.id
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  site_config {
    remote_debugging_enabled = false
    remote_debugging_version = "VS2019"
    vnet_route_all_enabled   = false
    application_stack {
      java_server         = "JBOSSEAP"
      java_server_version = 7
      java_version        = "11"
    }
  }

  app_settings = {
    https_only                      = true
    POSTGRES_CONNECTION_URL         = "jdbc:postgresql://${azurerm_postgresql_server.server.fqdn}:5432/monolith?sslmode=require"
    POSTGRES_SERVER_ADMIN_FULL_NAME = "azureadmin@${var.postgresql_name}"
    POSTGRES_SERVER_ADMIN_PASSWORD  = random_password.password.result
  }
}
