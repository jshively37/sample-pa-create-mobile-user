terraform {
  required_version = ">= 1.5"

  required_providers {
    scm = {
      source = "PaloAltoNetworks/scm"
    }
  }
}

# Credentials come from the environment so no secrets are committed:
#   export SCM_CLIENT_ID=...  SCM_CLIENT_SECRET=...  SCM_SCOPE="tsg_id:<your-tsg-id>"
provider "scm" {}
