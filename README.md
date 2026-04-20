# Entra ID & AD Configuration


Hi, This is a hybrid identity lab built from scratch. An on-premises Active Directory synced to Microsoft Entra ID via Entra Connect, three custom applications authenticated with two different SSO protocols (SAML 2.0 and OIDC + PKCE), Conditional Access policies enforcing MFA and blocking legacy authentication, and five operational runbooks for common hybrid identity incidents.

> 🤖 **AI Disclosure:** The three Flask applications were built with the assistance of Claude (Anthropic AI). All infrastructure decisions, Entra configuration, AD architecture, Conditional Access policy design, troubleshooting, and deployment were executed hands-on. AI was used as a coding accelerator, the same way engineers use it in real-world environments.

---

## 📺 Demo Walkthrough

- ### [Watch the Demo Video 🚀](#) <!-- Replace with actual YouTube link -->

---

## 1. Purpose

This project simulates a production hybrid identity environment for a mid-sized organization (SSO Labs Robotics). The goal was to build, configure, and operationally validate the full identity lifecycle — from on-premises Active Directory through cloud sync to Entra ID, SSO-enabled applications, Conditional Access enforcement, and incident response readiness.

The lab answers a specific set of enterprise IAM questions hands-on:

- How do you sync an on-premises AD population to Entra ID and control what syncs?
- How do SAML 2.0 and OIDC + PKCE differ at the protocol level, and when do you choose one over the other?
- How do you build Conditional Access policies that enforce MFA without locking out emergency access?
- How do you automate directory queries using Microsoft Graph API with the client credentials flow?
- How do you diagnose the five most common hybrid identity incidents — sync failures, CA blocks, SAML assertion errors, MFA lockouts, and missing users?

Everything runs on a live Windows Server 2025 domain controller with a real Entra ID P1 tenant (`ssolabs1001.onmicrosoft.com`).

---

## 2. Workflow Outline

### Phase A — Requirements & Scope Definition

1. **Define the company identity** — SSO Labs Robotics, a Zürich-headquartered robotics research company with employees and short-term contractors handling sensitive IP.
2. **Design two user populations** — Employees (long-term, full app access, 4 departments) and Contractors (90–180 day tenure, restricted to project-specific resources only). Each population maps to a distinct AD OU and Entra group.
3. **Scope three application archetypes** — RoboFleet Portal (SAML 2.0 enterprise app), ResearchHub (OIDC app registration with Graph API integration), LabOps Console (originally planned as Entra Application Proxy, pivoted to OIDC confidential client due to P2 licensing requirement).
4. **Write the Conditional Access policy baseline** — CA-001: MFA for all users. CA-002: MFA for admin directory roles. CA-003: Block legacy authentication. CA-004: Compliant device requirement (deferred — Intune not configured).
5. **Create the break-glass account** — `bga001@ssolabs1001.onmicrosoft.com` with Global Administrator role, no MFA registered, excluded from CA-001 and CA-002 but not CA-003.
6. **Map policy intent to IAM vocabulary** — Six mappings connecting business rules (e.g., "contractors get restricted access") to specific Entra objects (e.g., `GRP_Contractors → excluded from ResearchHub app assignment`).

### Phase B — Architecture Design

7. **Diagram the AD → Entra Connect sync pipeline** — OU scoping filters, attribute flow direction, Password Hash Sync on a 2-minute channel, delta sync on a 30-minute cycle.
8. **Diagram the SSO trust flows** — SAML SP-initiated flow (AuthnRequest → Entra authentication → signed XML assertion → ACS URL) alongside OIDC authorization code + PKCE flow (code challenge → Entra → authorization code → token exchange with verifier → Graph API calls).
9. **Diagram the Conditional Access evaluation chain** — Four signal categories (user/group, device state, location, risk score) evaluated in parallel, most restrictive policy wins, three outcomes (grant, grant with controls, block).
10. **Diagram the diagnostic log pipeline** — Sign-in logs, audit logs, and provisioning logs flowing to Entra log store, queryable via Graph API, Entra portal UI, and Log Analytics with KQL.

### Phase C — Implementation

11. **Build three Flask applications** — RoboFleet Portal on port 5004 (SAML with assertion viewer page), ResearchHub on port 5005 (OIDC with live Graph group membership and token claims page), LabOps Console on port 5006 (OIDC with equipment scheduling dashboard). All three launch simultaneously via `start-all.ps1`.
12. **Register apps in Entra ID** — RoboFleet as an Enterprise App with SAML SSO configuration (ACS URL, entity ID, signing certificate). ResearchHub and LabOps as App Registrations with confidential client credentials, redirect URIs, and API permissions (`User.Read`, `Group.Read.All` with admin consent).
13. **Create 66 test users in Active Directory** — PowerShell script populating seven OUs under `_EMEA\SSOLabs` (Research, Engineering, Operations, IT, Robotics contractors, Firmware contractors, Contract Engineers). All users have Department, Title, and Company attributes. A mock HR CSV with 19 columns serves as the source-of-truth artifact.
14. **Install and configure Entra Connect** — Customize path with OU scoping to `_EMEA\SSOLabs\Employees` and `_EMEA\SSOLabs\Contractors` only. Password Hash Sync enabled. `mS-DS-ConsistencyGuid` as source anchor. Dedicated `MSOL_` service account created automatically.
15. **Create and sync four AD security groups** — `SSO-Employees` (48 members), `SSO-Contractors` (18 members), `SSO-Admins` (8 members, IT department), `SSO-AllUsers` (66 members). Groups synced to Entra after correcting OU scope to include the Groups OU.
16. **Assign groups to enterprise apps** — Employees get access to all three apps. Contractors assigned to RoboFleet and LabOps only — explicitly excluded from ResearchHub per the Phase A access policy.
17. **Disable Security Defaults and build three CA policies** — Security Defaults disabled (cannot coexist with custom CA). CA-001, CA-002, and CA-003 created and enabled with correct targeting and exclusions.

### Phase D — Integration Testing

18. **Capture and annotate a live SAML assertion** — Intercepted the base64-encoded SAMLResponse from RoboFleet's ACS POST via browser DevTools. Decoded and annotated every element: Response ID, Issuer (Entra STS), NameID, SubjectConfirmation, Conditions (NotBefore/NotOnOrAfter), AudienceRestriction, `authnmethodsreferences` (proof of MFA completion), `objectidentifier` (immutable user ID).
19. **Decode OIDC JWT claims** — Captured ID token claims from ResearchHub's Profile & Claims page. Mapped `aud`, `iss`, `oid`, `sub`, `exp`, `tid`, and `ver` claims. Confirmed cross-protocol consistency: both the SAML assertion and the JWT carry the same `oid` and `tid` values for the same user authenticating through two different protocols.
20. **Build a Microsoft Graph client credentials script** — `graph_client_credentials.py` authenticates as the ResearchHub application (no user present) using MSAL and the OAuth 2.0 client credentials flow. Calls `GET /users` (200 OK, 66 users) and `GET /groups` (200 OK, 7 groups) with Application permissions (`User.Read.All`, `Group.Read.All`). Verified group membership counts match AD source.
21. **Test Conditional Access with What If** — Simulated Elena Vasquez (employee) via browser → CA-001 fires, requires MFA. Simulated same user via Exchange ActiveSync → CA-001 and CA-003 both fire, block wins (legacy auth cannot perform MFA). Confirmed block always overrides grant when multiple policies match.

### Phase E — Operational Readiness

22. **Develop five incident runbooks (42 total diagnostic steps):**
    - **RB-001: Entra Connect sync failure** — Sync Service Manager, connector space inspection, delta vs. full sync decision, export error diagnosis (InvalidSoftMatch, AttributeValueMustBeUnique, DataValidationFailed, LargeObject).
    - **RB-002: CA blocking legitimate users** — Sign-in log analysis, error code mapping (53003 = CA block, 50076 = MFA required, 50097 = device non-compliant), What If simulation, policy adjustment without weakening security.
    - **RB-003: SAML assertion failure** — Certificate thumbprint comparison, ACS URL mismatch detection, clock skew diagnosis, correct cert rotation procedure (generate → update SP → activate in IdP).
    - **RB-004: MFA registration lockout** — Identity verification (out-of-band, never trust email/chat alone), Temporary Access Pass issuance, `Get-MgUserAuthenticationMethod` for current method inventory.
    - **RB-005: AD user not appearing in Entra** — OU scoping verification, connector space search, delta vs. full sync selection (full sync required after scope changes), attribute validation.
23. **Build an interactive runbook reference application** — Process Street-style HTML app with expandable step-by-step procedures, inline PowerShell commands, decision trees, error code reference tables, and click-to-complete progress tracking.
24. **Train on two IAM Incident Simulator versions** — V1 (guided decision-tree with 18 scenarios across all five categories) and V2 (free-form text input requiring diagnostic recall without multiple-choice guardrails).
25. **Establish a universal diagnostic framework** — Four phases that apply to every identity incident: (1) Verify the source, (2) Find the gap, (3) Fix at the source, (4) Document and prevent.

---

## 3. Evidence

<!-- Replace placeholder links with actual URLs -->

### Video
- [Full Lab Walkthrough](#) <!-- YouTube link -->

### Screenshots
- Entra ID tenant dashboard showing 66 synced users and Entra Connect status
- Active Directory Users and Computers — OU structure under `_EMEA\SSOLabs`
- Okta-style Entra Enterprise App SAML configuration (RoboFleet)
- ResearchHub App Registration — redirect URIs, API permissions, admin consent
- Conditional Access policies list — CA-001, CA-002, CA-003 all enabled
- What If simulation results — CA-001 and CA-003 firing on legacy auth attempt
- RoboFleet SAML Assertion Viewer page — decoded AttributeStatement claims
- ResearchHub Profile & Claims page — JWT claims and live Graph `/me` response
- Entra Connect Synchronization Service Manager — successful export cycle
- Graph client credentials script terminal output — 66 users, 7 groups returned

### Lab Artifacts
- `graph_client_credentials.py` — App-only Graph API authentication script
- `start-all.ps1` — PowerShell launcher for all three Flask apps
- `Create-SSOLabsUsers.ps1` — AD user population script (66 users, 7 OUs)
- `Create-SSOLabsGroups.ps1` — AD security group creation and membership script
- `SSOLabs_HR_Database.csv` — Mock HR source-of-truth (19 columns, 66 records)
- Decoded SAML assertion XML (annotated)
- Five operational runbooks (HTML application)
- IAM Incident Simulator V1 and V2 (HTML applications)

---

## 4. Problems Resolved
 
### Dev Program sandbox eligibility blocked
**Symptom:** Both new and existing Microsoft accounts returned "You don't currently qualify for a Microsoft 365 Developer Program sandbox subscription."
 
**Root cause:** Microsoft tightened eligibility to require an active Visual Studio subscription or proven account history.
 
**Resolution:** Provisioned a real Entra ID P1 tenant via the M365 E3 trial instead. All Conditional Access, MFA, and group-based access features are available under P1.
 
---
 
### App Proxy blade returns 404 — licensing gap
**Symptom:** Navigating to the Entra Application Proxy configuration returned a 404.
 
**Root cause:** Application Proxy requires Entra ID P2 or Entra Private Access licensing. The M365 E3 trial only includes P1.
 
**Resolution:** Pivoted LabOps Console from App Proxy to a direct Entra OIDC confidential client implementation. Documented the production App Proxy architecture (connector outbound tunnel, pre-authentication, no inbound firewall ports) as a portfolio note.
 
---
 
### OIDC state mismatch — session cookie dropped on cross-origin redirect
**Symptom:** `State mismatch — stored: None` after Entra redirected back to the Flask app.
 
**Root cause:** Flask's default signed cookie session was dropped during the cross-site redirect to Entra and back. The browser's SameSite cookie policy prevented the session cookie from being sent on the return POST.
 
**Resolution:** Switched to `flask-session` with filesystem backend for server-side session storage. Set `SESSION_COOKIE_SAMESITE=Lax` and `SESSION_COOKIE_SECURE=False` (required for HTTP in a homelab environment).
 
---
 
### MSAL reserved scope error
**Symptom:** `ValueError: cannot use reserved scope values (openid, profile, email)`
 
**Root cause:** These scopes were explicitly passed in `config.py`, but MSAL adds them automatically and rejects duplicates.
 
**Resolution:** Removed `openid`, `profile`, and `email` from the SCOPE configuration. MSAL handles these internally.
 
---
 
### AADSTS7000218 — client assertion or client secret required
**Symptom:** Entra rejected the token exchange with error `AADSTS7000218`.
 
**Root cause:** The app registration had a Web redirect URI type configured, but public client flows were also enabled — sending conflicting signals to Entra about the client type.
 
**Resolution:** Switched to `ConfidentialClientApplication` in MSAL with a real client secret. Disabled the public client toggle in the app registration.
 
---
 
### Entra Connect — IE Enhanced Security Configuration blocking authentication popup
**Symptom:** The Entra Connect installer could not complete the Entra authentication step because the popup was blocked.
 
**Root cause:** Internet Explorer Enhanced Security Configuration was enabled on Windows Server 2025, blocking the OAuth redirect to `login.microsoftonline.com`.
 
**Resolution:** Disabled IE ESC via Server Manager → Local Server → IE Enhanced Security Configuration → Off for both Administrators and Users.
 
---
 
### Entra Connect — Enterprise Admin account rejected as sync account
**Symptom:** Attempting to use the existing AD Administrator account as the sync service account was blocked.
 
**Root cause:** Entra Connect explicitly prevents using Enterprise Admin or Domain Admin accounts as its service account for least-privilege compliance.
 
**Resolution:** Selected "Create new AD account" — Entra Connect created a dedicated `MSOL_` service account with the minimum required permissions automatically.
 
---
 
### Groups OU not syncing after group creation
**Symptom:** Four AD security groups created in `_EMEA\SSOLabs\Groups` were not appearing in Entra.
 
**Root cause:** The Groups OU was intentionally excluded from the initial Entra Connect OU scope (it was empty at the time). After groups were created and populated, the scope was never updated.
 
**Resolution:** Re-ran the Entra Connect "Customize synchronization options" wizard, added the Groups OU to the sync scope, and triggered a full sync (delta sync cannot detect objects in a newly scoped OU).
 
---
 
### ADSync module not loading in PowerShell 7
**Symptom:** `BadImageFormatException` when importing the ADSync module in PowerShell 7 on the ARM Windows Server.
 
**Root cause:** The ADSync module is compiled against the .NET runtime in Windows PowerShell 5.1 and is incompatible with PowerShell 7.
 
**Resolution:** Used Synchronization Service Manager (GUI) for sync operations instead. Documented this as a critical environment note in the operational runbooks.
 
---
 
### Security Defaults blocking CA policy creation
**Symptom:** Conditional Access policies could not be created or enabled.
 
**Root cause:** Security Defaults was still active on the tenant. Security Defaults and Conditional Access cannot run simultaneously.
 
**Resolution:** Disabled Security Defaults via Entra ID → Overview → Properties → Manage Security Defaults. Selected reason: "My organization is using Conditional Access."
 
---
 
## Environment
 
| Component | Detail |
|-----------|--------|
| On-prem domain | yearwood.local |
| Domain controller | Windows Server 2025 (ARM VM) |
| Cloud tenant | ssolabs1001.onmicrosoft.com |
| Entra ID plan | Premium P1 (via M365 E3 trial) |
| Identity sync | Entra Connect — Password Hash Sync, 30-min delta cycle |
| User population | 66 users (48 employees, 18 contractors) across 7 OUs |
| Security groups | 4 AD groups synced to Entra (SSO-Employees, SSO-Contractors, SSO-Admins, SSO-AllUsers) |
| Applications | RoboFleet (SAML, port 5004), ResearchHub (OIDC, port 5005), LabOps (OIDC, port 5006) |
| CA policies | CA-001 (MFA all users), CA-002 (MFA admin roles), CA-003 (block legacy auth) |
| App runtime | Python 3.11 / Flask / MSAL |
| Break-glass | bga001@ssolabs1001.onmicrosoft.com — Global Admin, no MFA, excluded from CA-001/002 |
 
---
 
## Project Status
 
- ✅ Entra ID P1 tenant provisioned and configured
- ✅ Active Directory — 66 users, 13 OUs, 4 security groups
- ✅ Entra Connect installed — Password Hash Sync, OU scoping, delta sync running
- ✅ Three Flask apps built, registered in Entra, and authenticated (SAML + OIDC)
- ✅ Group-to-app assignments enforcing employee/contractor access boundaries
- ✅ Three Conditional Access policies enabled (MFA, admin MFA, block legacy auth)
- ✅ SAML assertion captured, decoded, and annotated element by element
- ✅ OIDC JWT claims decoded and cross-referenced with SAML assertion (same oid/tid)
- ✅ Microsoft Graph client credentials script working with Application permissions
- ✅ CA policies validated via What If simulation
- ✅ Five operational runbooks built (42 diagnostic steps)
- ✅ IAM Incident Simulator V1 (guided) and V2 (free-form) completed
---
 
*Hybrid Identity Lab — Built as a portfolio project demonstrating end-to-end hybrid identity configuration, multi-protocol SSO, Conditional Access enforcement, Graph API automation, and operational incident response with Entra ID and Active Directory.*
