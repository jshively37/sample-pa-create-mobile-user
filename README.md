# Runbook: Configure Mobile Users (GlobalProtect) in Prisma Access

This runbook walks through onboarding mobile users to Prisma Access using the
GlobalProtect app, managed from **Strata Cloud Manager (SCM)**. The same
settings exist in Panorama-managed Prisma Access under the *Mobile_User_Container*
template/device group; menu names differ slightly and are noted where relevant.

> Menu paths reflect SCM at the time of writing and change between releases.
> Verify against the current Palo Alto Networks docs before executing in production.

> **Proof of value:** track pass/fail for every step in [POV-CHECKLIST.md](POV-CHECKLIST.md).

---

## 1. Overview

```
 User device (GlobalProtect)
        |
        |  1. Portal login (SAML/LDAP) -> gets config + gateway list
        v
 Prisma Access Portal  --->  2. Gateway selection (best location)
        |
        v
 Prisma Access Gateway (IPsec/SSL tunnel)  --->  Internet / SaaS / Private apps
                                                     (via Service Connection)
```

| Item | Value (fill in) |
|---|---|
| Tenant / TSG ID | `__________` |
| Portal hostname | `__________.gpcloudservice.com` (or custom FQDN) |
| IdP | Entra ID / Okta / Ping / LDAP |
| Mobile user IP pool | `10.x.x.0/xx` |
| Locations | e.g. US East, US West, EU West |
| Change ticket | `CHG__________` |

## 2. Prerequisites checklist

- [ ] Prisma Access license active with **Mobile Users – GlobalProtect** subscription and sufficient user count
- [ ] Role with permission to edit Prisma Access config (Superuser / Prisma Access admin)
- [ ] Mobile user **IP address pool** that does not overlap with on-prem, cloud, or branch ranges (typically /16 or larger; allocated per compute location)
- [ ] **Infrastructure subnet** (default /24 minimum, recommend /23) reserved and non-overlapping
- [ ] Identity provider details: SAML metadata XML or LDAP/Cloud Identity Engine (CIE) directory
- [ ] DNS servers (internal and/or public) for mobile users; internal domain list if split-DNS is needed
- [ ] (If accessing private apps) Service Connection or Remote Network already built and routing validated
- [ ] Certificates: portal/gateway server certificate (Palo Alto-managed default, or custom from a public CA for custom FQDN)
- [ ] Endpoint distribution method for the GlobalProtect app (MDM/Intune/Jamf/GPO)
- [ ] Network allowance: end users can reach `*.gpcloudservice.com` on TCP/UDP 443 (and UDP 4501 for IPsec)

## 3. Step-by-step configuration

### Step 1 – Enable and size Mobile Users

1. **Workflows → Prisma Access Setup → GlobalProtect** (SCM).
2. Open **Infrastructure Settings** and set:
   - **Infrastructure subnet** (e.g. `172.16.0.0/23`)
   - **Infrastructure BGP AS** (if using service connections)
3. Open **GlobalProtect → Mobile Users → Settings** and set **IP Pools** per region/compute location.
4. Add **DNS** settings: select *Cloud-Provided*, *Internal*, or *Custom* servers and add internal domains for split-DNS.

### Step 2 – Configure authentication

1. **Manage → Configuration → NGFW and Prisma Access → Identity Services → Authentication** (path varies).
2. Add a **SAML IdP server profile**:
   - Upload IdP metadata or enter SSO URL, Entity ID and IdP certificate
   - Enable *Validate Identity Provider Certificate*
   - Set the username attribute (e.g. `username`/`email`)
3. Create an **Authentication Profile** referencing the server profile.
   - Set *Allow List* to `all` or specific user groups.
4. Create an **Authentication Policy rule** (Authentication Rules) if using MFA/Cloud Authentication Service.
5. (Optional) Configure **Cloud Identity Engine** to supply user/group mappings for policy.

### Step 3 – Build the GlobalProtect Portal

1. **GlobalProtect → Mobile Users → GlobalProtect Portal**.
2. Set:
   - **Portal hostname** (default `*.gpcloudservice.com`, or a custom domain with CNAME to the Prisma Access portal)
   - **Authentication Profile** from Step 2
   - **Certificate** – default or custom
3. Under **Agent**, create an **Agent Config** (App Settings):
   - Name, *User/Group* scope (match on groups from CIE/LDAP/SAML)
   - **Connect Method**: `User-logon (Always On)` (recommended) or `On-demand`
   - **Internal Host Detection** (optional) for on-prem users
   - **Tunnel settings**: IPsec preferred with SSL fallback
   - **App Config**: allow/disallow disconnect, uninstall, logout behavior
   - **Split tunnel**: Include/exclude by domain, app, or route if required
   - **HIP**: enable HIP data collection if posture-based policy is used
4. Order agent configs from most-specific to least-specific.

### Step 4 – Configure Gateways / Locations

1. **GlobalProtect → Mobile Users → Locations** (*Onboarding* in some versions).
2. Select **locations** (compute locations) to deploy gateways, e.g. `US East`, `US West`, `UK`, `Germany`.
3. Choose **Manual** or **Best available** gateway selection in the agent config.
4. Save and verify the gateway FQDNs.

### Step 5 – Security policy

1. **Security Services → Security Policy**: create rules for the `mobile-users` zone/folder (**Mobile Users** folder in SCM):
   - Allow users to Internet/SaaS with Security Profile Group (AV, Anti-Spyware, Vuln, URL Filtering, WildFire, DNS Security)
   - Allow users to private apps (trust → service connection) by user/group
   - Final rule: deny and log
2. Add **Decryption** policy if required (needs forward-trust cert pushed to endpoints).
3. Add **HIP Profiles/Objects** for device posture where applicable.

### Step 6 – Push configuration

1. Click **Push Config** (SCM) and select **Prisma Access** (Mobile Users).
2. Monitor under **Operations → Push Status** until the job shows **Success**.
3. For Panorama-managed: *Panorama → Cloud Services → Configuration → Mobile Users – GlobalProtect → Onboarding*, then *Commit → Commit and Push → Prisma Access*.

### Step 7 – Deploy the GlobalProtect app

1. Download the app from **GlobalProtect → Mobile Users → GlobalProtect App** (or the Palo Alto support portal).
2. Distribute with MDM/GPO with pre-deployment settings:
   - Windows: `msiexec /i GlobalProtect64.msi PORTAL="<portal-fqdn>" /quiet`
   - macOS: `defaults write /Library/Preferences/com.paloaltonetworks.GlobalProtect.settings Palo\ Alto\ Networks '{GlobalProtect={PanSetup={Portal="<portal-fqdn>";};};}'`
3. Instruct users to sign in with their corporate credentials.

## 4. Validation

| Check | How | Expected |
|---|---|---|
| Portal reachable | `curl -I https://<portal-fqdn>/global-protect/prelogin.esp` | HTTP 200 / XML response |
| Auth works | Sign in on a test device | SAML redirect, then connected |
| Tunnel up | GlobalProtect app → *Settings → Connection* | Gateway shown, assigned IP from pool |
| Internet access | Browse a test site | Allowed per policy; logs present |
| Private app access | Reach internal app by FQDN | Resolves via internal DNS, reachable |
| Logging | SCM **Incidents & Alerts → Log Viewer** | Traffic/GP logs for the test user |
| Monitoring | **Insights → Prisma Access → Users** | Test user active in correct location |

## 5. Troubleshooting

| Symptom | Likely cause | Action |
|---|---|---|
| App cannot find portal | DNS/FQDN typo, portal not pushed | Verify push success, test `prelogin.esp` |
| SAML loop / failure | Clock skew, wrong ACS URL, expired IdP cert | Check IdP logs; re-import metadata |
| Connected, no traffic | Missing security rule or IP pool routing | Check policy and log viewer; verify return routes |
| Cannot reach private apps | Service connection/BGP down, overlapping subnets | Check service connection status and routes |
| Slow or wrong gateway | Gateway selection by priority/best-available | Review agent config and locations |
| Certificate warnings | Custom FQDN w/o trusted cert | Install full chain on portal/gateway |
| Decrypted sites fail | Forward-trust CA not on endpoint | Deploy CA via MDM |

Client logs: `PanGPS.log` and `PanGPA.log`
- Windows: `C:\Program Files\Palo Alto Networks\GlobalProtect\`
- macOS: `~/Library/Logs/PaloAltoNetworks/GlobalProtect/`

## 6. Rollback

1. Revert to the previous config version: **Operations → Snapshots / Config Versions → Load → Push**.
2. Or disable the new agent config (move it below the default, or remove user group scope) and push.
3. Notify users; they will receive the prior config at next portal check-in.

## 7. Optional: Automation

Prisma Access can be automated using the Strata Cloud Manager API
(`https://api.sase.paloaltonetworks.com`) with OAuth2 client credentials from a service account.

```bash
# Obtain token (replace values; never commit secrets)
curl -s -u "$CLIENT_ID:$CLIENT_SECRET" \
  -d "grant_type=client_credentials&scope=tsg_id:$TSG_ID" \
  https://auth.apps.paloaltonetworks.com/oauth2/access_token

# Push candidate config to the Mobile Users folder
curl -s -X POST https://api.sase.paloaltonetworks.com/sse/config/v1/config-versions/candidate:push \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"folders": ["Mobile Users"], "description": "Mobile user onboarding"}'
```

The Terraform provider `PaloAltoNetworks/scm` and the `pan-scm-sdk` Python SDK
can also manage these objects as code.

**Example Terraform:** see [`terraform/`](terraform/README.md) for a validated example that creates the
SAML profile, authentication profile, and mobile user security rules (Steps 2 and 5).
The provider has no GlobalProtect portal/gateway resources, so Steps 1, 3 and 4 remain manual or API-driven.

## 8. Sign-off

| Role | Name | Date |
|---|---|---|
| Implementer | | |
| Reviewer | | |
| Security approval | | |
