terraform {
  required_version = ">=1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
    storage_account_name = "ozgursunexp"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    resource_group_name  = "sunexpress"
  }
}
provider "azurerm" {
  features {}
}

# ihtiyacim olan local variable'lari tanimliyorum
locals {
  resource_group_name = "sunexpress"
  sql_server_name     = "sozgur-sunexp-sql"
  location            = "westeurope"
}


# Azure'da daha önceden olusturdugum ACR kaynagiyle ilgili bilgi cekmem lazim
# bu nedenle bir data kaynağı olarak ekliyorum
data "azurerm_container_registry" "acr" {
  name                = "ozgursunexpress"
  resource_group_name = local.resource_group_name
  
}


# SQL Server oluşturuyorum
resource "azurerm_mssql_server" "server" {
  name                         = local.sql_server_name
  resource_group_name          = local.resource_group_name
  location                     = local.location
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  version                      = "12.0"
}

# Azure kaynaklarinden sql'e ulasmak icin firewall kuralı
resource "azurerm_mssql_firewall_rule" "fwruleazure" {
  name             = "fwruleazure"
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# kendi makinemden ulasmak icin firewall kuralı
resource "azurerm_mssql_firewall_rule" "fwrulemyip" {
  name             = "fwrulemyip"
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = "46.154.30.165"
  end_ip_address   = "46.154.30.165"
}

# Bu sql'e bağli mydrivingDB adında Database oluşturuyorum
resource "azurerm_mssql_database" "db" {
  name      = var.sql_db_name
  server_id = azurerm_mssql_server.server.id
  max_size_gb    = 2
  sku_name = "Basic"
}


# dataload ediyorum
resource "null_resource" "dataload" {
  depends_on = [ azurerm_mssql_database.db ]
  provisioner "local-exec" {
    command = "docker run -e SQLFQDN=${local.sql_server_name}.database.windows.net -e SQLUSER=${var.admin_username} -e SQLPASS=${var.admin_password} -e SQLDB=mydrivingDB openhack/data-load:v1"
  }
}


# app service plan oluşturuyorum
resource "azurerm_service_plan" "asp" {
  name                = "ozgur-asp"
  location            = local.location
  resource_group_name = local.resource_group_name
  os_type = "Linux"
  sku_name = "P1v3"
}

# poi web app oluşturuyorum
resource "azurerm_linux_web_app" "poi" {
  name                = "poi-ozgur"
  resource_group_name = local.resource_group_name
  location            = local.location
  service_plan_id     = azurerm_service_plan.asp.id
  
    site_config {
        application_stack {
          docker_image_name = "tripinsights/poi:1.0"
          docker_registry_url = "https://${data.azurerm_container_registry.acr.name}.azurecr.io"
          docker_registry_username = data.azurerm_container_registry.acr.admin_username
          docker_registry_password = data.azurerm_container_registry.acr.admin_password
        }
    }

    app_settings = {
        SQL_SERVER = "${local.sql_server_name}.database.windows.net",
        SQL_PASSWORD = "${var.admin_password}",
        SQL_USER = "${var.admin_username}",
        SQL_DBNAME = "mydrivingDB",
        ASPNETCORE_ENVIRONMENT = "Local"
    }
    
    identity {
        type = "SystemAssigned"
    }   
}




# trips web app oluşturuyorum
resource "azurerm_linux_web_app" "trips" {
  name                = "trips-ozgur"
  resource_group_name = local.resource_group_name
  location            = local.location
  service_plan_id     = azurerm_service_plan.asp.id
  
    site_config {
        application_stack {
          docker_image_name = "tripinsights/trips:1.0"
          docker_registry_url = "https://${data.azurerm_container_registry.acr.name}.azurecr.io"
          docker_registry_username = data.azurerm_container_registry.acr.admin_username
          docker_registry_password = data.azurerm_container_registry.acr.admin_password
        }
    }

    app_settings = {
        SQL_SERVER = "${local.sql_server_name}.database.windows.net",
        SQL_PASSWORD = "${var.admin_password}",
        SQL_USER = "${var.admin_username}",
        SQL_DBNAME = "mydrivingDB",
        OPENAPI_DOCS_URI = "http://1.1.1.1"
    }

    identity {
        type = "SystemAssigned"
    }   
}

# userprofile web app oluşturuyorum
resource "azurerm_linux_web_app" "userprofile" {
  name                = "userprofile-ozgur"
  resource_group_name = local.resource_group_name
  location            = local.location
  service_plan_id     = azurerm_service_plan.asp.id
  
    site_config {
        application_stack {
          docker_image_name = "tripinsights/userprofile:1.0"
          docker_registry_url = "https://${data.azurerm_container_registry.acr.name}.azurecr.io"
          docker_registry_username = data.azurerm_container_registry.acr.admin_username
          docker_registry_password = data.azurerm_container_registry.acr.admin_password
        }
    }

    app_settings = {
        SQL_SERVER = "${local.sql_server_name}.database.windows.net",
        SQL_PASSWORD = "${var.admin_password}",
        SQL_USER = "${var.admin_username}",
        SQL_DBNAME = "mydrivingDB"
    }

    identity {
        type = "SystemAssigned"
    }   
}

# user-java web app oluşturuyorum
resource "azurerm_linux_web_app" "user-java" {
  name                = "user-java-ozgur"
  resource_group_name = local.resource_group_name
  location            = local.location
  service_plan_id     = azurerm_service_plan.asp.id
  
    site_config {
        application_stack {
          docker_image_name = "tripinsights/user-java:1.0"
          docker_registry_url = "https://${data.azurerm_container_registry.acr.name}.azurecr.io"
          docker_registry_username = data.azurerm_container_registry.acr.admin_username
          docker_registry_password = data.azurerm_container_registry.acr.admin_password
        }
    }

    app_settings = {
        SQL_SERVER = "${local.sql_server_name}.database.windows.net",
        SQL_PASSWORD = "${var.admin_password}",
        SQL_USER = "${var.admin_username}",
        SQL_DBNAME = "mydrivingDB"
    }

    identity {
        type = "SystemAssigned"
    }   
}

# tripviewer web app oluşturuyorum
resource "azurerm_linux_web_app" "tripviewer" {
  name                = "tripviewer-ozgur"
  resource_group_name = local.resource_group_name
  location            = local.location
  service_plan_id     = azurerm_service_plan.asp.id
  
    site_config {
        application_stack {
          docker_image_name = "tripinsights/tripviewer:1.0"
          docker_registry_url = "https://${data.azurerm_container_registry.acr.name}.azurecr.io"
          docker_registry_username = data.azurerm_container_registry.acr.admin_username
          docker_registry_password = data.azurerm_container_registry.acr.admin_password
        }
    }

    app_settings = {
          USERPROFILE_API_ENDPOINT = "http://userprofile-ozgur.azurewebsites.net",
          TRIPS_API_ENDPOINT = "http://trips-ozgur.azurewebsites.net",
          BING_MAPS_KEY = "bingmapskey"
    }

    identity {
        type = "SystemAssigned"
    }   
}