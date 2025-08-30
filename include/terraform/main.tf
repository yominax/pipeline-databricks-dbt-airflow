# resource random_pet is from terraform used for avoiding name conflicts
resource "random_pet" "prefix" {
  length = 1
}

# Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${random_pet.prefix.id}-rg-data-pipeline"
  location = "Southeast Asia"
}

data "azurerm_client_config" "current" {}

# Azure Data Lake Storage
resource "azurerm_storage_account" "adls" {
  name                     = "${random_pet.prefix.id}adlsdatapipeline"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(["bronze", "silver", "gold"])
  name                  = "${random_pet.prefix.id}-${each.value}"
  storage_account_id    = azurerm_storage_account.adls.id
  container_access_type = "private"
}

# Azure Data Factory (ADF)
# resource "azurerm_data_factory" "adf" {
#   name                = "${random_pet.prefix.id}-adf-datapipeline"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   identity {
#     type = "SystemAssigned"
#   }
# }

# Azure Databricks
resource "azurerm_databricks_workspace" "databricks" {
  name                = "${random_pet.prefix.id}-databricks-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "standard"
}

# Azure Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "${random_pet.prefix.id}-kv-datapipeline"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_key_vault_access_policy" "user_policy" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id  # Replace with your app's object ID

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete", 
    "Recover", 
    "Backup", 
    "Restore", 
    "Purge"
  ]
}

# resource "azurerm_key_vault_access_policy" "adf_policy" {
#   key_vault_id = azurerm_key_vault.kv.id

#   tenant_id = data.azurerm_client_config.current.tenant_id
#   object_id = azurerm_data_factory.adf.identity[0].principal_id  # Referencing directly from the ADF resource

#   secret_permissions = [
#     "Get",
#     "List",
#     "Set",
#     "Delete", 
#     "Recover", 
#     "Backup", 
#     "Restore", 
#     "Purge"
#   ]
# }

# Azure Synapse Analytics Workspace
resource "azurerm_synapse_workspace" "synapse" {
  name                                  = "${random_pet.prefix.id}-synapse-datapipeline"
  location                              = azurerm_resource_group.rg.location
  resource_group_name                   = azurerm_resource_group.rg.name
  storage_data_lake_gen2_filesystem_id  = azurerm_storage_data_lake_gen2_filesystem.adls_fs.id
  sql_administrator_login               = "synapseadmin"
  sql_administrator_login_password      = "Password123!" # Use a secure variable in production

  identity {
    type = "SystemAssigned"
  }
}

# Azure Data Lake Storage Filesystem for Synapse
resource "azurerm_storage_data_lake_gen2_filesystem" "adls_fs" {
  name               = "${random_pet.prefix.id}-fs" # Dynamically generated name
  storage_account_id = azurerm_storage_account.adls.id
}

# Additional Role Assignment for Managed Identity (Optional for troubleshooting)
resource "azurerm_role_assignment" "synapse_workspace_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_synapse_workspace.synapse.identity[0].principal_id
}

# Role Assignment for Synapse Workspace to access Storage
resource "azurerm_role_assignment" "synapse_storage_access" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.synapse.identity[0].principal_id
}
