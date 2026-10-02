# Proof of Value Checklist: Prisma Access Mobile Users (GlobalProtect)

Track pass/fail for each step in the [runbook](README.md). Mark each row
**Pass**, **Fail**, **N/A** or **Blocked**, and record evidence (screenshot, log
excerpt, ticket) and any notes.

| Field | Value |
|---|---|
| Customer / project | |
| Tenant / TSG ID | |
| POV start date | |
| POV end date | |
| Owner | |
| Success criteria agreed with customer | |

**Status key:** ☐ Not started | ✅ Pass | ❌ Fail | ⛔ Blocked | N/A

---

## 1. Prerequisites

| # | Item | Status | Evidence / Notes |
|---|---|---|---|
| 1.1 | Prisma Access license active, Mobile Users subscription with enough users | ☐ | |
| 1.2 | Admin role can edit Prisma Access config | ☐ | |
| 1.3 | Mobile user IP pool reserved, no overlap with on-prem/cloud/branch | ☐ | |
| 1.4 | Infrastructure subnet reserved, no overlap | ☐ | |
| 1.5 | IdP details available (SAML metadata or LDAP/CIE) | ☐ | |
| 1.6 | DNS servers and internal domain list identified | ☐ | |
| 1.7 | Service Connection / Remote Network ready (if private apps in scope) | ☐ | |
| 1.8 | Portal/gateway certificate decided (default or custom FQDN) | ☐ | |
| 1.9 | App distribution method chosen (MDM/GPO) | ☐ | |
| 1.10 | Endpoints can reach `*.gpcloudservice.com` on TCP/UDP 443 and UDP 4501 | ☐ | |
| 1.11 | Test users and test devices identified (list below) | ☐ | |

Test users/devices: _______________________________________________

## 2. Configuration

| # | Step | Status | Evidence / Notes |
|---|---|---|---|
| 2.1 | **Step 1:** Infrastructure subnet set | ☐ | |
| 2.2 | **Step 1:** Mobile user IP pools set per location | ☐ | |
| 2.3 | **Step 1:** DNS settings (and split-DNS domains) configured | ☐ | |
| 2.4 | **Step 2:** SAML server profile created, IdP cert validated | ☐ | |
| 2.5 | **Step 2:** Authentication profile created, allow list set | ☐ | |
| 2.6 | **Step 2:** MFA / authentication policy configured (if in scope) | ☐ | |
| 2.7 | **Step 3:** Portal hostname and certificate configured | ☐ | |
| 2.8 | **Step 3:** Agent config created (connect method, tunnel, split tunnel, HIP) | ☐ | |
| 2.9 | **Step 3:** Agent configs ordered most-specific to least-specific | ☐ | |
| 2.10 | **Step 4:** Gateway locations selected and FQDNs verified | ☐ | |
| 2.11 | **Step 5:** Internet/SaaS allow rule with security profile group | ☐ | |
| 2.12 | **Step 5:** Private app allow rule by user/group (if in scope) | ☐ | |
| 2.13 | **Step 5:** Final deny-and-log rule | ☐ | |
| 2.14 | **Step 5:** Decryption / HIP policy (if in scope) | ☐ | |
| 2.15 | **Step 6:** Push Config completed with status Success | ☐ | |
| 2.16 | **Step 7:** GlobalProtect app deployed to test devices | ☐ | |
| 2.17 | **Optional:** Terraform `plan`/`apply` succeeds for SAML, auth profile, rules | ☐ | |

## 3. Validation (runbook section 4)

| # | Test | Expected | Status | Evidence / Notes |
|---|---|---|---|---|
| 3.1 | Portal reachable (`prelogin.esp`) | HTTP 200 / XML | ☐ | |
| 3.2 | User authenticates via SAML | Redirect to IdP, then connected | ☐ | |
| 3.3 | MFA prompt appears (if in scope) | MFA challenge succeeds | ☐ | |
| 3.4 | Tunnel established | Gateway shown, IP from pool | ☐ | |
| 3.5 | Correct gateway / location selected | Closest or configured location | ☐ | |
| 3.6 | Internet access allowed | Test site loads | ☐ | |
| 3.7 | Security profiles enforced | Test malware / blocked URL category blocked | ☐ | |
| 3.8 | Private app access | App reachable by FQDN via internal DNS | ☐ | |
| 3.9 | Traffic denied by default rule | Unlisted traffic blocked and logged | ☐ | |
| 3.10 | Logs visible in Log Viewer | Traffic/GP logs for test user | ☐ | |
| 3.11 | User visible in Insights | Active in correct location | ☐ | |
| 3.12 | Reconnect after network change | Tunnel re-establishes | ☐ | |
| 3.13 | Test on each OS in scope (Windows / macOS / mobile) | Connects on all | ☐ | |
| 3.14 | Rollback tested (revert config version, push) | Prior config restored | ☐ | |

## 4. Success criteria (fill in with customer)

| # | Criterion | Target | Result | Status |
|---|---|---|---|---|
| 4.1 | Connection success rate | | | ☐ |
| 4.2 | Time to connect | | | ☐ |
| 4.3 | Application performance vs. current VPN | | | ☐ |
| 4.4 | Admin time to onboard a new user group | | | ☐ |
| 4.5 | | | | ☐ |

## 5. Issues log

| # | Date | Step | Description | Owner | Resolution | Status |
|---|---|---|---|---|---|---|
| | | | | | | |

## 6. Summary and sign-off

| Section | Pass | Fail | Blocked | N/A |
|---|---|---|---|---|
| 1. Prerequisites | | | | |
| 2. Configuration | | | | |
| 3. Validation | | | | |
| 4. Success criteria | | | | |

Overall result: ☐ Pass ☐ Pass with exceptions ☐ Fail

| Role | Name | Date |
|---|---|---|
| Implementer | | |
| Customer sponsor | | |
| Reviewer | | |
