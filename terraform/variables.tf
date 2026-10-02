variable "folder" {
  description = "SCM folder that holds the mobile user configuration."
  type        = string
  default     = "Mobile Users"
}

variable "idp_entity_id" {
  description = "IdP Entity ID from your SAML metadata."
  type        = string
}

variable "idp_sso_url" {
  description = "IdP SSO (login) URL from your SAML metadata."
  type        = string
}

variable "idp_certificate" {
  description = "Name of the IdP signing certificate already imported into SCM."
  type        = string
}

variable "allowed_user_groups" {
  description = "User groups allowed to authenticate. Use [\"all\"] to allow everyone."
  type        = list(string)
  default     = ["all"]
}

variable "security_profile_group" {
  description = "Name of an existing security profile group to attach to the allow rules."
  type        = string
  default     = "best-practice"
}
