# Entra ID & AD Configuration


Hi, This is a hybrid identity lab built from scratch. 

An on-premises Active Directory synced to Microsoft Entra ID via Entra Connect, three custom applications authenticated with two different SSO protocols (SAML 2.0 and OIDC + PKCE), Conditional Access policies enforcing MFA and blocking legacy authentication, and five operational runbooks for common hybrid identity incidents.

> 🤖 **Claude Used:** The three Flask applications were built with the assistance of Claude (Anthropic AI). All infrastructure decisions, Entra configuration, AD architecture, Conditional Access policy design, troubleshooting, and deployment were executed hands-on. AI was used as a coding accelerator, the same way engineers use it in real-world environments.

---

## 📺 Demo Walkthrough

- ### [Video Coming Soon 🚀](#) <!-- Replace with actual YouTube link -->

---

## 1. Purpose

This project simulates a production hybrid identity environment for a mid-sized organization (SSO Labs Robotics). The goal was to build, configure, and operationally validate the full identity lifecycle. From on-premises Active Directory through cloud sync to Entra ID, SSO-enabled applications, Conditional Access enforcement, and incident response readiness.

The lab answers a specific set of enterprise IAM questions hands-on:

- How do you sync an on-premises AD population to Entra ID and control what syncs?
- How do SAML 2.0 and OIDC + PKCE differ at the protocol level, and when do you choose one over the other?
- How do you build Conditional Access policies that enforce MFA without locking out emergency access?
- How do you automate directory queries using Microsoft Graph API with the client credentials flow?
- How do you diagnose the five most common hybrid identity incidents — sync failures, CA blocks, SAML assertion errors, MFA lockouts, and missing users?

Everything runs on a live Windows Server 2025 domain controller with a real Entra ID P1 tenant (`ssolabs1001.onmicrosoft.com`).


---

## 2. Workflow Outline (23 Steps Total)

### Phase 1 — Requirements & Scope Definition

1. **Define the company identity** — SSO Labs Robotics, a Zürich-headquartered robotics research company with employees and short-term contractors handling sensitive IP.<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/fee8d1ec-993e-4486-89cb-2cea490edcec" />
2. **Design two user populations** — Employees (long-term, full app access, 4 departments) and Contractors (90–180 day tenure, restricted to project-specific resources only). Each population maps to a distinct AD OU and Entra group.<img width="751" height="796" alt="image" src="https://github.com/user-attachments/assets/12ff5912-1ff5-4d46-b2d9-40fd8f9062dc" />
3. **Scope three application archetypes** — RoboFleet Portal (SAML 2.0 enterprise app), ResearchHub (OIDC app registration with Graph API integration), LabOps Console (originally planned as Entra Application Proxy, pivoted to OIDC confidential client due to P2 licensing requirement).<img width="645" height="834" alt="image" src="https://github.com/user-attachments/assets/f7de15ba-f9f2-41af-b0a3-e44c3a5c83f7" />
4. **Write the Conditional Access policy baseline** — CA-001: MFA for all users. CA-002: MFA for admin directory roles. CA-003: Block legacy authentication. CA-004: Compliant device requirement (deferred — Intune not configured).<img width="404" height="162" alt="image" src="https://github.com/user-attachments/assets/f6f141d8-6e5e-447c-bd65-0770b9863163" />
5. **Create the break-glass account** — `bga001@ssolabs1001.onmicrosoft.com` with Global Administrator role, no MFA registered, excluded from CA-001 and CA-002 but not CA-003.<img width="1914" height="820" alt="image" src="https://github.com/user-attachments/assets/87a9ca9e-eeeb-4c49-ad6f-c2e3b069d505" />
6. **Map policy intent to IAM vocabulary** — Six mappings connecting business rules (e.g., "contractors get restricted access") to specific Entra objects (e.g., `GRP_Contractors → excluded from ResearchHub app assignment`).<img width="563" height="422" alt="image" src="https://github.com/user-attachments/assets/263115a6-f4e6-4333-8761-e68a135c7e87" />

### Phase 2 — Architecture Design

7. **Diagram the AD → Entra Connect sync pipeline** — OU scoping filters, attribute flow direction, Password Hash Sync on a 2-minute channel, delta sync on a 30-minute cycle.<img width="1062" height="793" alt="image" src="https://github.com/user-attachments/assets/3efe7fdd-623e-45ff-8788-3eba6b50207f" />
8. **Diagram the SSO trust flows** — SAML SP-initiated flow (AuthnRequest → Entra authentication → signed XML assertion → ACS URL) alongside OIDC authorization code + PKCE flow (code challenge → Entra → authorization code → token exchange with verifier → Graph API calls).
9. **Diagram the Conditional Access evaluation chain** — Four signal categories (user/group, device state, location, risk score) evaluated in parallel, most restrictive policy wins, three outcomes (grant, grant with controls, block).<img width="666" height="830" alt="image" src="https://github.com/user-attachments/assets/4b9b1e2f-7036-4ed3-9fbb-5b20baa611a3" />

10. **Diagram the diagnostic log pipeline** — Sign-in logs, audit logs, and provisioning logs flowing to Entra log store, queryable via Graph API, Entra portal UI, and Log Analytics with KQL.

### Phase 3 — Implementation

11. **Build three Flask applications** — RoboFleet Portal on port 5004 (SAML with assertion viewer page), ResearchHub on port 5005 (OIDC with live Graph group membership and token claims page), LabOps Console on port 5006 (OIDC with equipment scheduling dashboard). All three launch simultaneously via `start-all.ps1`.<img width="1900" height="1005" alt="image" src="https://github.com/user-attachments/assets/bb0d8392-222b-434a-88b9-c34765f10d2a" /><img width="1677" height="891" alt="image" src="https://github.com/user-attachments/assets/88d3fb56-5b6f-432f-87e0-a7de57560e26" /><img width="1669" height="899" alt="image" src="https://github.com/user-attachments/assets/eeec782c-a17c-47c3-8fc2-651496e5a13b" /><img width="1675" height="905" alt="image" src="https://github.com/user-attachments/assets/39c81016-45b6-42d8-8771-851bf373a5fd" />
12. **Register apps in Entra ID** — RoboFleet as an Enterprise App with SAML SSO configuration (ACS URL, entity ID, signing certificate). ResearchHub and LabOps as App Registrations with confidential client credentials, redirect URIs, and API permissions (`User.Read`, `Group.Read.All` with admin consent).<img width="1910" height="804" alt="image" src="https://github.com/user-attachments/assets/e1612547-49d4-4a1a-8c66-78f0a57be16a" />
13. **Create 66 test users in Active Directory** — PowerShell script populating seven OUs under `_EMEA\SSOLabs` (Research, Engineering, Operations, IT, Robotics contractors, Firmware contractors, Contract Engineers). All users have Department, Title, and Company attributes. A mock HR CSV with 19 columns serves as the source-of-truth artifact.<img width="1903" height="1004" alt="image" src="https://github.com/user-attachments/assets/fa95ab23-a102-471b-b7ee-b6721ef880b3" /><img width="1101" height="322" alt="image" src="https://github.com/user-attachments/assets/55aa5fd5-a621-456e-9021-ca00da5de6ad" /><img width="2916" height="1726" alt="image" src="https://github.com/user-attachments/assets/67d0c158-f43f-4dd1-ab00-0f58179dd20d" />
14. **Install and configure Entra Connect** — Customize path with OU scoping to `_EMEA\SSOLabs\Employees` and `_EMEA\SSOLabs\Contractors` only. Password Hash Sync enabled. `mS-DS-ConsistencyGuid` as source anchor. Dedicated `MSOL_` service account created automatically.<img width="1900" height="1005" alt="image" src="https://github.com/user-attachments/assets/e67c9fc8-638c-4629-b109-c114aa969b24" />
15. **Create and sync four AD security groups** — `SSO-Employees` (48 members), `SSO-Contractors` (18 members), `SSO-Admins` (8 members, IT department), `SSO-AllUsers` (66 members). Groups synced to Entra after correcting OU scope to include the Groups OU.
16. **Assign groups to enterprise apps** — Employees get access to all three apps. Contractors assigned to RoboFleet and LabOps only — explicitly excluded from ResearchHub per the Phase 1 access policy.<img width="1917" height="963" alt="image" src="https://github.com/user-attachments/assets/1e2e03f2-413c-485a-8f12-b0026c1694a4" /><img width="1907" height="959" alt="image" src="https://github.com/user-attachments/assets/41df94c8-991a-495f-b84d-129f0cb7ebe9" />
17. **Disable Security Defaults and build three CA policies** — Security Defaults disabled (cannot coexist with custom CA). CA-001, CA-002, and CA-003 created and enabled with correct targeting and exclusions.<img width="1907" height="968" alt="image" src="https://github.com/user-attachments/assets/30db239e-9d6a-47b8-865d-81d787435043" />


### Phase 4 — Integration Testing 
[Click Here To See Google Doc - Includes Step 18-21](https://docs.google.com/document/d/1C52Dnqa0pmlo9tpmXYEC3HHetz3j6Bw7-4jijEgBCt8/edit?usp=sharing)

18. **Capture and annotate a live SAML assertion** — Intercepted the base64-encoded SAMLResponse from RoboFleet's ACS POST via browser DevTools. Decoded and annotated every element: Response ID, Issuer (Entra STS), NameID, SubjectConfirmation, Conditions (NotBefore/NotOnOrAfter), AudienceRestriction, `authnmethodsreferences` (proof of MFA completion), `objectidentifier` (immutable user ID).<img width="3418" height="2088" alt="image" src="https://github.com/user-attachments/assets/ae815477-a399-4a5d-9cbe-461b51bef21f" /><img width="3390" height="1904" alt="image" src="https://github.com/user-attachments/assets/46e46137-410c-4378-b9cb-eddfeac61e8c" /><img width="1645" height="991" alt="image" src="https://github.com/user-attachments/assets/7b810506-ee29-4752-8ea0-52e9b1c3b202" />
19. **Decode OIDC JWT claims** — Captured ID token claims from ResearchHub's Profile & Claims page. Mapped `aud`, `iss`, `oid`, `sub`, `exp`, `tid`, and `ver` claims. Confirmed cross-protocol consistency: both the SAML assertion and the JWT carry the same `oid` and `tid` values for the same user authenticating through two different protocols.<img width="1636" height="1170" alt="image" src="https://github.com/user-attachments/assets/eebb6641-9304-47d1-9cdb-a04199035ffe" />
20. **Build a Microsoft Graph client credentials script** — `graph_client_credentials.py` authenticates as the ResearchHub application (no user present) using MSAL and the OAuth 2.0 client credentials flow. Calls `GET /users` (200 OK, 66 users) and `GET /groups` (200 OK, 7 groups) with Application permissions (`User.Read.All`, `Group.Read.All`). Verified group membership counts match AD source.
21. **Test Conditional Access with What If** — Simulated Elena Vasquez (employee) via browser → CA-001 fires, requires MFA. Simulated same user via Exchange ActiveSync → CA-001 and CA-003 both fire, block wins (legacy auth cannot perform MFA). Confirmed block always overrides grant when multiple policies match.<img width="1584" height="1178" alt="image" src="https://github.com/user-attachments/assets/62cebe11-127f-40b4-b244-ffc06ba05c63" />


### Phase 5 — Operational Readiness
[Click Here To See Process.St Style Runbooks](https://github.com/EvanHYearwood/Entra-ID_AD_Prod-Environment/tree/main/Operational%20Runbooks)

22. **Develop five incident runbooks (42 total diagnostic steps):**
    - **RB-001: Entra Connect sync failure** — Sync Service Manager, connector space inspection, delta vs. full sync decision, export error diagnosis (InvalidSoftMatch, AttributeValueMustBeUnique, DataValidationFailed, LargeObject).
    - **RB-002: CA blocking legitimate users** — Sign-in log analysis, error code mapping (53003 = CA block, 50076 = MFA required, 50097 = device non-compliant), What If simulation, policy adjustment without weakening security.
    - **RB-003: SAML assertion failure** — Certificate thumbprint comparison, ACS URL mismatch detection, clock skew diagnosis, correct cert rotation procedure (generate → update SP → activate in IdP).
    - **RB-004: MFA registration lockout** — Identity verification (out-of-band, never trust email/chat alone), Temporary Access Pass issuance, `Get-MgUserAuthenticationMethod` for current method inventory.
    - **RB-005: AD user not appearing in Entra** — OU scoping verification, connector space search, delta vs. full sync selection (full sync required after scope changes), attribute validation.
23. **Build an interactive runbook reference application** — Process Street-style HTML app with expandable step-by-step procedures, inline PowerShell commands, decision trees, error code reference tables, and click-to-complete progress tracking.

---

## 3. Problems Resolved
 
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
