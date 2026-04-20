$password = ConvertTo-SecureString "SSOLabs2026!" -AsPlainText -Force

$users = @(
    # Research — 14 users
    @{First="Elena";     Last="Vasquez";     OU="OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Lab Director";            Dept="Research"},
    @{First="Kai";       Last="Nakamura";    OU="OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Senior Researcher";        Dept="Research"},
    @{First="Ingrid";    Last="Bergmann";    OU="OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Senior Researcher";        Dept="Research"},
    @{First="Luca";      Last="Ferretti";    OU="OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Research Scientist";       Dept="Research"},
    @{First="Amara";     Last="Diallo";      OU="OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Research Scientist";       Dept="Research"},
    @{First="Felix";     Last="Kramer";      OU="OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Research Analyst";         Dept="Research"},
    @{First="Sofie";     Last="Andersen";    OU="OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Research Analyst";         Dept="Research"},
    @{First="Tariq";     Last="Mansouri";    OU="OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Data Scientist";           Dept="Research"},
    @{First="Hana";      Last="Novak";       OU="OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Data Scientist";           Dept="Research"},
    @{First="Mathieu";   Last="Leclerc";     OU="OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Simulation Engineer";      Dept="Research"},
    @{First="Zara";      Last="Ahmed";       OU="OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Simulation Engineer";      Dept="Research"},
    @{First="Nils";      Last="Halvorsen";   OU="OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Research Associate";       Dept="Research"},
    @{First="Chiara";    Last="Lombardi";    OU="OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Research Associate";       Dept="Research"},
    @{First="Ryo";       Last="Fujimoto";    OU="OU=Research,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Research Associate";       Dept="Research"},

    # Engineering — 16 users
    @{First="Marco";     Last="Rossi";       OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Lead Robotics Engineer";  Dept="Engineering"},
    @{First="Aisha";     Last="Okonkwo";     OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Lead Firmware Engineer";  Dept="Engineering"},
    @{First="Stefan";    Last="Huber";       OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Senior Robotics Engineer";Dept="Engineering"},
    @{First="Linnea";    Last="Svensson";    OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Senior Robotics Engineer";Dept="Engineering"},
    @{First="Emre";      Last="Yilmaz";      OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Robotics Engineer";       Dept="Engineering"},
    @{First="Fatima";    Last="El-Amin";     OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Robotics Engineer";       Dept="Engineering"},
    @{First="Jonas";     Last="Weber";       OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Robotics Engineer";       Dept="Engineering"},
    @{First="Priya";     Last="Chandrasekaran"; OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Firmware Engineer";   Dept="Engineering"},
    @{First="Tobias";    Last="Richter";     OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Firmware Engineer";       Dept="Engineering"},
    @{First="Yuna";      Last="Park";        OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Firmware Engineer";       Dept="Engineering"},
    @{First="Nico";      Last="Bauer";       OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Software Engineer";       Dept="Engineering"},
    @{First="Alicia";    Last="Torres";      OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Software Engineer";       Dept="Engineering"},
    @{First="Dimitri";   Last="Papadopoulos";OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Software Engineer";       Dept="Engineering"},
    @{First="Leila";     Last="Nazari";      OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Systems Engineer";        Dept="Engineering"},
    @{First="Pieter";    Last="Van Den Berg"; OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Systems Engineer";       Dept="Engineering"},
    @{First="Miriam";    Last="Goldstein";   OU="OU=Engineering,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="QA Engineer";             Dept="Engineering"},

    # Operations — 10 users
    @{First="Lars";      Last="Hoffmann";    OU="OU=Operations,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Operations Manager";       Dept="Operations"},
    @{First="Beatrice";  Last="Muller";      OU="OU=Operations,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Senior Lab Technician";    Dept="Operations"},
    @{First="Kaspar";    Last="Zimmermann";  OU="OU=Operations,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Lab Technician";           Dept="Operations"},
    @{First="Adaeze";    Last="Obi";         OU="OU=Operations,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Lab Technician";           Dept="Operations"},
    @{First="Henrik";    Last="Lindqvist";   OU="OU=Operations,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Lab Technician";           Dept="Operations"},
    @{First="Claudia";   Last="Schneider";   OU="OU=Operations,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Logistics Coordinator";    Dept="Operations"},
    @{First="Omar";      Last="Hassan";      OU="OU=Operations,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Logistics Coordinator";    Dept="Operations"},
    @{First="Vera";      Last="Sokolova";    OU="OU=Operations,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Facilities Manager";       Dept="Operations"},
    @{First="Bruno";     Last="Carvalho";    OU="OU=Operations,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Equipment Specialist";     Dept="Operations"},
    @{First="Astrid";    Last="Eriksen";     OU="OU=Operations,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Safety Officer";           Dept="Operations"},

    # IT — 8 users
    @{First="Priya";     Last="Sharma";      OU="OU=IT,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="IT Manager";                      Dept="IT"},
    @{First="Lukas";     Last="Fischer";     OU="OU=IT,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Systems Administrator";           Dept="IT"},
    @{First="Nadia";     Last="Petrov";      OU="OU=IT,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Systems Administrator";           Dept="IT"},
    @{First="Samuel";    Last="Osei";        OU="OU=IT,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Security Analyst";                Dept="IT"},
    @{First="Annika";    Last="Holm";        OU="OU=IT,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Network Engineer";                Dept="IT"},
    @{First="Kenji";     Last="Watanabe";    OU="OU=IT,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Identity Engineer";               Dept="IT"},
    @{First="Isabelle";  Last="Dupont";      OU="OU=IT,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Helpdesk Analyst";                Dept="IT"},
    @{First="Reza";      Last="Tehrani";     OU="OU=IT,OU=Employees,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Helpdesk Analyst";                Dept="IT"},

    # Contractors — Robotics — 7 users
    @{First="Diego";     Last="Reyes";       OU="OU=Robotics,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="External Robotics Specialist"; Dept="Contractors"},
    @{First="Tomas";     Last="Novotny";     OU="OU=Robotics,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Robotics Consultant";          Dept="Contractors"},
    @{First="Sienna";    Last="Marchetti";   OU="OU=Robotics,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Robotics Consultant";          Dept="Contractors"},
    @{First="Kwame";     Last="Asante";      OU="OU=Robotics,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Autonomous Systems Specialist"; Dept="Contractors"},
    @{First="Petra";     Last="Kowalski";    OU="OU=Robotics,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Robotics Technician";          Dept="Contractors"},
    @{First="Anders";    Last="Lindberg";    OU="OU=Robotics,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Motion Systems Engineer";       Dept="Contractors"},
    @{First="Yemi";      Last="Adeyemi";     OU="OU=Robotics,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Robotics Integration Specialist"; Dept="Contractors"},

    # Contractors — Firmware — 6 users
    @{First="Yuki";      Last="Tanaka";      OU="OU=Firmware,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Firmware Consultant";          Dept="Contractors"},
    @{First="Aleksei";   Last="Volkov";      OU="OU=Firmware,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Firmware Consultant";          Dept="Contractors"},
    @{First="Chloe";     Last="Dubois";      OU="OU=Firmware,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Embedded Systems Consultant";  Dept="Contractors"},
    @{First="Mikael";    Last="Virtanen";    OU="OU=Firmware,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Firmware Security Consultant"; Dept="Contractors"},
    @{First="Zanele";    Last="Dlamini";     OU="OU=Firmware,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Embedded Software Specialist"; Dept="Contractors"},
    @{First="Rafael";    Last="Mendoza";     OU="OU=Firmware,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Firmware Validation Engineer"; Dept="Contractors"},

    # Contractors — Contract Engineers — 5 users
    @{First="Sam";       Last="Fletcher";    OU="OU=Contract Engineers,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Project Engineer";     Dept="Contractors"},
    @{First="Ines";      Last="Rodrigues";   OU="OU=Contract Engineers,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Systems Engineer";      Dept="Contractors"},
    @{First="Florian";   Last="Braun";       OU="OU=Contract Engineers,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Integration Engineer";  Dept="Contractors"},
    @{First="Mei";       Last="Chen";        OU="OU=Contract Engineers,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Mechanical Engineer";   Dept="Contractors"},
    @{First="Arjun";     Last="Patel";       OU="OU=Contract Engineers,OU=Contractors,OU=SSOLabs,OU=_EMEA,DC=yearwood,DC=local"; Title="Control Systems Engineer"; Dept="Contractors"}
)

$password = ConvertTo-SecureString "SSOLabs2026!" -AsPlainText -Force
$created = 0
$skipped = 0

foreach ($u in $users) {
    $sam = "$($u.First.ToLower()).$($u.Last.ToLower())"
    $sam = $sam -replace '\s','' -replace "'",''
    if ($sam.Length -gt 20) { $sam = $sam.Substring(0, 20) }
    $upn = "$sam@yearwood.local"

    if (Get-ADUser -Filter {SamAccountName -eq $sam} -ErrorAction SilentlyContinue) {
        Write-Host "Skipped (exists): $upn" -ForegroundColor Yellow
        $skipped++
        continue
    }

    try {
        New-ADUser `
            -GivenName $u.First `
            -Surname $u.Last `
            -Name "$($u.First) $($u.Last)" `
            -SamAccountName $sam `
            -UserPrincipalName $upn `
            -Title $u.Title `
            -Department $u.Dept `
            -Company "SSO Labs" `
            -Path $u.OU `
            -AccountPassword $password `
            -PasswordNeverExpires $true `
            -ChangePasswordAtLogon $false `
            -Enabled $true
        Write-Host "Created: $upn  [$($u.Title)]" -ForegroundColor Green
        $created++
    } catch {
        Write-Host "Error: $upn  $_" -ForegroundColor Red
    }
}

Write-Host "`nDone. Created: $created  Skipped: $skipped  Total attempted: $($users.Count)" -ForegroundColor Cyan