output "sql_server_name" {
  value = azurerm_mssql_server.server.name
}

output "sql_admin_username" {
  value = var.admin_username
}

output "sql_admin_password" {
  value = var.admin_password
  sensitive = true 
}


output "webapp_url_poi" {
  value = azurerm_linux_web_app.poi.default_hostname
}

output "webapp_url_trips" {
  value = azurerm_linux_web_app.trips.default_hostname
}

output "webapp_url_userprofile" {
  value = azurerm_linux_web_app.userprofile.default_hostname
}


output "webapp_url_user-java" {
  value = azurerm_linux_web_app.user-java.default_hostname
}

output "webapp_url_tripviewer" {
  value = azurerm_linux_web_app.tripviewer.default_hostname
}