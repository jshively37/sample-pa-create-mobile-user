# Example Terraform: Prisma Access mobile user building blocks

Companion to the [runbook](../README.md). Uses the
[`PaloAltoNetworks/scm`](https://registry.terraform.io/providers/PaloAltoNetworks/scm/latest/docs)
provider to manage Strata Cloud Manager objects.

## What this creates

| Resource | Runbook step |
|---|---|
| `scm_saml_server_profile` | Step 2 – SAML IdP profile |
| `scm_authentication_profile` | Step 2 – authentication profile |
| `scm_security_rule` (allow + deny-all) | Step 5 – mobile user security policy |

## What it does NOT create

The provider does not currently expose resources for the GlobalProtect
**portal, agent configs, gateways/locations, IP pools, or infrastructure
settings** (runbook Steps 1, 3, 4). Configure those in Strata Cloud Manager
(or the SCM API) and reference the authentication profile created here.
It also does not push the candidate config; do that from SCM
(**Push Config**) or the config-versions API.

## Usage

```bash
export SCM_CLIENT_ID="..."
export SCM_CLIENT_SECRET="..."
export SCM_SCOPE="tsg_id:<your-tsg-id>"

cp terraform.tfvars.example terraform.tfvars   # edit values
terraform init
terraform plan
terraform apply
```

Prerequisites: an SCM service account with edit rights, the IdP signing
certificate already imported into SCM, and an existing security profile group.
Resource arguments were taken from the provider docs; run `terraform validate`
and `plan` against your tenant, as schemas change between provider versions.
