variable "admin_username" {
  type        = string
  description = "The administrator username of the SQL logical server."
  default     = "azureadmin"
}

variable "admin_password" {
  type        = string
  description = "The administrator password of the SQL logical server."
  sensitive   = true
  default     = "qwq123AS!ozgur"
}

variable "sql_db_name" {
  type        = string
  description = "The name of the SQL database."
  default     = "mydrivingDB"  
}