resource "azurerm_public_ip" "agw" {
  name                = "appGatewayPublicIP-odoo"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

locals {
  backend_address_pool_name      = "${var.virutal_network_name}-beap"
  frontend_port_name             = "${var.virutal_network_name}-feport"
  frontend_ip_configuration_name = "${var.virutal_network_name}-feip"
  http_setting_name              = "${var.virutal_network_name}-be-htst"
  listener_name                  = "${var.virutal_network_name}-httplstn"
  request_routing_rule_name      = "${var.virutal_network_name}-rqrt"
  redirect_configuration_name    = "${var.virutal_network_name}-rdrcfg"
}

resource "azurerm_web_application_firewall_policy" "agw" {
  name                = "odoo-wafpolicy"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
      rule_group_override {
        rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
        rule {
          id      = "920300"
          enabled = true
          action  = "Log"
        }

        rule {
          id      = "920440"
          enabled = true
          action  = "Block"
        }
      }
    }
  }
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = "appGateway-odoo"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 5
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = var.agw_subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.agw.id
  }

  backend_address_pool {
    name  = local.backend_address_pool_name
    fqdns = ["odoo-app.whitebush-7cb016e2.eastus2.azurecontainerapps.io"]
  }

  backend_http_settings {
    name                                = local.http_setting_name
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = "container-app-probe"
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  probe {
    name                                      = "container-app-probe"
    # host                                      = "10.2.0.1"
    protocol                                  = "Https"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 15
    unhealthy_threshold                       = 5
    pick_host_name_from_backend_http_settings = true
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.agw.id

}
