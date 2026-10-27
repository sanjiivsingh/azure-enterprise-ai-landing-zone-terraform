output "workspace_id" {
  value       = azurerm_log_analytics_workspace.this.id
  description = "Log Analytics Workspace ID."
}

output "app_insights_id" {
  value       = azurerm_application_insights.this.id
  description = "Application Insights ID."
}

output "app_insights_connection_string" {
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
  description = "Application Insights connection string."
}
