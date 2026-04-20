# Add-SSOLabsGroupMembers.ps1
# Populates SSO Labs AD groups with the correct user population

# ── Employees OU paths ──────────────────────────────────────────
$employeeOUs = @(
    "OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local",
    "OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local",
    "OU=Operations,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local",
    "OU=IT,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"
)

# ── Contractor OU paths ─────────────────────────────────────────
$contractorOUs = @(
    "OU=Robotics,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local",
    "OU=Firmware,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local",
    "OU=Contract Engineers,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"
)

# ── Admin users (IT department) ─────────────────────────────────
$adminSAMs = @(
    "priya.sharma",
    "lukas.fischer",
    "nadia.petrov",
    "samuel.osei",
    "annika.holm",
    "kenji.watanabe",
    "isabelle.dupont",
    "reza.tehrani"
)

# ── Helper: add members safely ──────────────────────────────────
function Add-Members {
    param($GroupName, $Members)
    $added = 0
    foreach ($m in $Members) {
        try {
            Add-ADGroupMember -Identity $GroupName -Members $m -ErrorAction Stop
            $added++
        } catch {
            Write-Host "  Warning: could not add $($m.SamAccountName) to $GroupName — $_" -ForegroundColor Yellow
        }
    }
    Write-Host "  Added $added members to $GroupName" -ForegroundColor Green
}

# ── Collect user objects ────────────────────────────────────────
Write-Host "`nCollecting employees..." -ForegroundColor Cyan
$employees = @()
foreach ($ou in $employeeOUs) {
    $employees += Get-ADUser -Filter * -SearchBase $ou -SearchScope OneLevel
}
Write-Host "  Found $($employees.Count) employees"

Write-Host "Collecting contractors..." -ForegroundColor Cyan
$contractors = @()
foreach ($ou in $contractorOUs) {
    $contractors += Get-ADUser -Filter * -SearchBase $ou -SearchScope OneLevel
}
Write-Host "  Found $($contractors.Count) contractors"

Write-Host "Collecting admins..." -ForegroundColor Cyan
$admins = @()
foreach ($sam in $adminSAMs) {
    $user = Get-ADUser -Filter {SamAccountName -eq $sam} -ErrorAction SilentlyContinue
    if ($user) {
        $admins += $user
    } else {
        Write-Host "  Warning: $sam not found" -ForegroundColor Yellow
    }
}
Write-Host "  Found $($admins.Count) admins"

$allUsers = $employees + $contractors

# ── Populate groups ─────────────────────────────────────────────
Write-Host "`nPopulating SSO-Employees..." -ForegroundColor Cyan
Add-Members -GroupName "SSO-Employees" -Members $employees

Write-Host "Populating SSO-Contractors..." -ForegroundColor Cyan
Add-Members -GroupName "SSO-Contractors" -Members $contractors

Write-Host "Populating SSO-Admins..." -ForegroundColor Cyan
Add-Members -GroupName "SSO-Admins" -Members $admins

Write-Host "Populating SSO-AllUsers..." -ForegroundColor Cyan
Add-Members -GroupName "SSO-AllUsers" -Members $allUsers

# ── Summary ─────────────────────────────────────────────────────
Write-Host "`n── Group membership summary ──────────────────────" -ForegroundColor Cyan
foreach ($g in @("SSO-Employees","SSO-Contractors","SSO-Admins","SSO-AllUsers")) {
    $count = (Get-ADGroupMember -Identity $g).Count
    Write-Host "  $g : $count members" -ForegroundColor White
}

Write-Host "`nDone. Run a delta sync to push groups to Entra:" -ForegroundColor Cyan
Write-Host "  Start-ADSyncSyncCycle -PolicyType Delta" -ForegroundColor White