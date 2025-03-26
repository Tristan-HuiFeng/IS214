data "azurerm_client_config" "current" {}

data "azurerm_key_vault_secret" "appuser" {
  name         = "db-appuser"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "apppassword" {
  name         = "db-apppassword"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "u" {
  name         = "db-user"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "p" {
  name         = "odoo-password"
  key_vault_id = var.key_vault_id
}

resource "azurerm_log_analytics_workspace" "odoo" {
  name                = "odoo-analytics"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "odoo" {
  name                       = "odoo-app-env"
  location                   = var.resource_group_location
  resource_group_name        = var.resource_group_name
  infrastructure_subnet_id   = var.app_subnet_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.odoo.id

}

resource "azurerm_user_assigned_identity" "odoo" {
  depends_on          = [azurerm_container_app_environment.odoo]
  location            = var.resource_group_location
  name                = "odoo-user"
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "odoo" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.odoo.principal_id
}

resource "azurerm_role_assignment" "kv_odoo" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.odoo.principal_id
}

resource "azurerm_role_assignment" "fs_odoo" {
  scope              = var.storage_account_id
  role_definition_id = "Storage File Data SMB Share Contributor"
  principal_id       = azurerm_user_assigned_identity.odoo.principal_id
}

resource "azurerm_key_vault_access_policy" "app" {
  key_vault_id                = var.key_vault_id
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  object_id                   = azurerm_user_assigned_identity.odoo.principal_id
  secret_permissions          = ["Get", "List"]
}

resource "azurerm_container_app" "app" {
  depends_on = [azurerm_container_app_environment.odoo]

  name                         = "odoo-app"
  container_app_environment_id = azurerm_container_app_environment.odoo.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Multiple"
  template {

    # volume {
    #   namename = "odoofs"

    #   storage_type = "Azure"
    # }
    
    container {
      name   = "odoo-app"
      image  = "${var.registry_server}/odoo17:v5"
      cpu    = 1
      memory = "2Gi"
      env {
        name  = "HOST"
        value = "odoodb-is214.postgres.database.azure.com"
      }
      # env {
      #   name  = "USER"
      #   value = ""
      # }
      # env {
      #   name  = "PASSWORD"
      #   value = ""
      # }
      env {
        name  = "USER"
        secret_name = "db-appuser"
      }
      env {
        name  = "PASSWORD"
        secret_name = "db-apppassword"
      }

      # volume_mounts {
      #   name = "odoofs"
      #   path = "/mnt/fileshare"
      # }

      # readiness_probe {
      #   port                    = 8069
      #   transport               = "HTTP"
      #   path                    = "/"
      #   initial_delay           = 60  
      #   interval_seconds        = 15
      #   timeout                 = 5
      #   success_count_threshold = 1
      #   failure_count_threshold = 5
      # }
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.odoo.id]
  }

  ingress {
    allow_insecure_connections = true
    target_port                = 8069
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
    external_enabled = true
  }

  secret {
    name  = "registry-password"
    value = var.acr_password
  }

  secret {
    name  = "db-appuser"
    // value = data.azurerm_key_vault_secret.db_user.value
    identity = azurerm_user_assigned_identity.odoo.id
    key_vault_secret_id = data.azurerm_key_vault_secret.appuser.id
  }

  secret {
    name  = "db-apppassword"
    // value = data.azurerm_key_vault_secret.db_password.value
    identity = azurerm_user_assigned_identity.odoo.id
    key_vault_secret_id = data.azurerm_key_vault_secret.apppassword.id
  }

  registry {
    server   = var.registry_server
    identity = azurerm_user_assigned_identity.odoo.id
    # username = var.acr_username
    # password_secret_name = "registry-password"
  }

    secret {
    name  = "db-user"
    // value = data.azurerm_key_vault_secret.db_password.value
    identity = azurerm_user_assigned_identity.odoo.id
    key_vault_secret_id = data.azurerm_key_vault_secret.u.id
  }

  secret {
    name  = "odoo-password"
    // value = data.azurerm_key_vault_secret.db_password.value
    identity = azurerm_user_assigned_identity.odoo.id
    key_vault_secret_id = data.azurerm_key_vault_secret.p.id
  }

}

resource "azurerm_container_app" "pgadmin4" {
  depends_on = [azurerm_container_app_environment.odoo]

  name                         = "pgadmin4"
  container_app_environment_id = azurerm_container_app_environment.odoo.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  template {
    container {
      name   = "pgadmin4"
      image  = "${var.registry_server}/pgadmin4:v2"
      cpu    = 1.0
      memory = "2Gi"



      readiness_probe {
        port                    = 80
        transport               = "HTTP"
        path                    = "/misc/ping"
        initial_delay           = 60
        interval_seconds        = 15
        timeout                 = 5
        success_count_threshold = 1
        failure_count_threshold = 5
      }
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.odoo.id]
  }

  ingress {
    allow_insecure_connections = true
    target_port                = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
    external_enabled = true
  }

  # secret {
  #   name  = "registry-password"
  #   value = var.acr_password
  # }

  registry {
    server   = var.registry_server
    identity = azurerm_user_assigned_identity.odoo.id
    # username = var.acr_username
    # password_secret_name = "registry-password"
  }

}
