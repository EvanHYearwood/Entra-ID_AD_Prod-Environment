# Create-SSOLabsGroups.ps1
# Creates the four SSO Labs security groups in the Groups OU

$groupsOU = "OU=Groups,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"

$groups = @(
    @{
        Name        = "SSO-Employees"
        Description = "All SSO Labs full-time employees — grants access to RoboFleet, ResearchHub, and LabOps"
    },
    @{
        Name        = "SSO-Contractors"
        Description = "All SSO Labs contractors — grants access to RoboFleet and LabOps only, excluded from ResearchHub"
    },
    @{
        Name        = "SSO-Admins"
        Description = "SSO Labs IT and administrative staff — elevated CA treatment and privileged app access"
    },
    @{
        Name        = "SSO-AllUsers"
        Description = "All SSO Labs users including employees and contractors — used for broad CA policy scoping"
    }
)

foreach ($g in $groups) {
    if (Get-ADGroup -Filter {Name -eq $g.Name} -ErrorAction SilentlyContinue) {
        Write-Host "Skipped (exists): $($g.Name)" -ForegroundColor Yellow
    } else {
        New-ADGroup `
            -Name $g.Name `
            -GroupScope Global `
            -GroupCategory Security `
            -Description $g.Description `
            -Path $groupsOU
        Write-Host "Created: $($g.Name)" -ForegroundColor Green
    }
}

Write-Host "`nDone. Four SSO Labs groups ready in $groupsOU" -ForegroundColor Cyan