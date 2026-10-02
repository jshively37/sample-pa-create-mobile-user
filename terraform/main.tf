# SAML IdP server profile (runbook Step 2)
resource "scm_saml_server_profile" "mobile_users" {
  folder = var.folder

  name                     = "pa-mobile-users-saml"
  certificate              = var.idp_certificate
  entity_id                = var.idp_entity_id
  sso_url                  = var.idp_sso_url
  sso_bindings             = "post"
  max_clock_skew           = 60
  validate_idp_certificate = true
}

# Authentication profile used by the GlobalProtect portal and gateways (Step 2)
resource "scm_authentication_profile" "mobile_users" {
  folder = var.folder

  name       = "pa-mobile-users-auth"
  allow_list = var.allowed_user_groups

  method = {
    saml_idp = {
      server_profile          = scm_saml_server_profile.mobile_users.name
      attribute_name_username = "username"
      enable_single_logout    = false
    }
  }
}

# Security policy for mobile users (Step 5)
resource "scm_security_rule" "mobile_users_internet" {
  folder   = var.folder
  name     = "mobile-users-to-internet"
  position = "pre"

  action      = "allow"
  from        = ["any"]
  to          = ["any"]
  source      = ["any"]
  destination = ["any"]
  source_user = ["any"]
  application = ["any"]
  service     = ["application-default"]
  category    = ["any"]

  profile_setting = {
    group = [var.security_profile_group]
  }

  log_end = true
}

resource "scm_security_rule" "mobile_users_deny_all" {
  folder   = var.folder
  name     = "mobile-users-deny-all"
  position = "post"

  action      = "deny"
  from        = ["any"]
  to          = ["any"]
  source      = ["any"]
  destination = ["any"]
  source_user = ["any"]
  application = ["any"]
  service     = ["any"]
  category    = ["any"]

  log_end = true
}
