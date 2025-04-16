<#
.SYNOPSIS
    Comprehensive Dell Bloatware removal (no UWP apps).

.DESCRIPTION
    1) Silently uninstalls all known Dell MSI packages by GUID.
    2) Silently uninstalls all known Dell EXE-based uninstallers.
    3) Dynamically scans the registry for any remaining “Dell” apps and uninstalls them.
    4) Deletes Dell scheduled tasks and services.

    Logs every action (and errors) to C:\Temp\DellBloatwareRemoval.log.
	
	a lot of GUIDS and Exe from https://gist.github.com/tsfahmed2/5385b56e9a2d387ca61b355b90541084
#>

# Prevent terminating errors from stopping the script
$ErrorActionPreference = 'Continue'

#region Configuration
# Path to log file
$LogFile = 'C:\Temp\DellBloatwareRemoval.log'

# MSI-based Dell applications (GUIDs, without braces)
$DellGuids = @(
    '5669AB71-1302-4412-8DA1-CB69CD7B7324', # Dell Command | Update for Windows 10
    '4CCADC13-F3AE-454F-B724-33F6D4E52022', # Dell Command | Update for Windows 10
    'EC542D5D-B608-4145-A8F7-749C02BE6D94', # Dell Command | Update for Windows 10
    '41D2D254-D869-4CD8-B440-5DF49083C4BA', # Dell Command | Update for Windows 10
    'D8AE5F9D-647C-49B4-A666-1C20B44EC0E1', # Dell Update
    '70E9F8CC-A23E-4C25-B292-C86C1821587C', # Dell Update for Windows 10
    'CC5730C7-C867-43BD-94DA-00BB3836906F', # Dell Digital Delivery Services
    '66E2407E-9001-483E-B2AA-7AEF97567143', # Dell Digital Delivery Services
    '81C48559-E2EB-4F18-9854-51331B9DB552', # Dell Digital Delivery Services
    '3722784A-D530-4C82-BB78-4DF3E1A4CAD9', # Dell Digital Delivery Services
    '693A23FB-F28B-4F7A-A720-4C1263F97F43', # Dell Digital Delivery Services
    '560DFD4A-23E2-45DD-A223-A4B3FA356913', # Dell Digital Delivery Services
    '6B8F1793-AB75-4A01-B72D-CC2B54B19759', # Dell Digital Delivery Services
    'AADBB088-81DE-4EC8-B176-D98669BE09D4', # SupportAssist Update Plugin
    'EDE60887-F1EA-4304-A3E9-806D29EEE3FB', # SupportAssist Update Plugin
    'C559D0AB-2D9E-4B59-B2B8-0C2061B3F9BC', # SupportAssist Update Plugin
    '8B6D8EEE-9EE4-4FA3-9EC6-87BE5D130CB6', # SupportAssist Update Plugin
    '8FA6BC9C-CF6A-45E7-92BD-1585DFAFB32C', # Dell SupportAssist Remediation
    '2B2C47D2-F037-4C03-B599-07D7AFE8DD54', # Dell SupportAssist Remediation
    '1906C253-4035-4CA5-A501-075E691CCEC9', # Dell SupportAssist Remediation
    'C4EF62FF-E6B9-4CE8-A514-1DDA49CB0C47', # Dell SupportAssist Remediation
    '795931D8-2EBF-4969-A678-4219B161F676', # Dell SupportAssist Remediation
    '10B1BCF9-4996-4270-A12D-1B1BFEEF979C', # Dell SupportAssist Remediation
    '61A1B864-0DAF-45A4-8184-5A0D347803B1', # Dell SupportAssist Remediation
    '6B991B44-B938-4902-BDF3-186CBDC62AD3', # Dell SupportAssist Remediation
    'E21419F5-2AA6-439C-B2C1-840083A05BC5', # Dell SupportAssist Remediation
    '28C1FA1E-C3B3-4257-A3F2-059EEA260C64', # Dell SupportAssist Remediation
    '398E49A0-84CA-43B5-A926-42EF68619E91', # Dell SupportAssist Remediation
    '3A0ECCB6-1034-440E-8672-C4E14CCB7689', # Dell SupportAssist
    '5106801D-CA18-4173-85B9-D74C33358F7F', # Dell SupportAssist
    '9EF0AEB0-9AD2-40E6-8667-D7520C508941', # Dell SupportAssist
    '71A59A4C-9348-4CA2-B98C-E422E14C9D31', # Dell SupportAssist
    'E0659C89-D276-4B77-A5EC-A8F2F042E78F', # Dell SupportAssist
    '900D0BCD-0B86-4DAA-B639-89BE70449569', # Dell SupportAssist OS Recovery Plugin for Dell Update
    '6DD27BB4-C350-414B-BC25-D33246605FB2', # Dell SupportAssist OS Recovery Plugin for Dell Update
    'A713BCAE-ED3C-43BA-834A-8D1E8773FF2C', # Dell SupportAssist OS Recovery Plugin for Dell Update
    '39BF0E71-7A16-4A80-BBCE-FBDD2D1CC2D5', # Dell SupportAssist OS Recovery Plugin for Dell Update
    '18469ED8-8C36-4CF7-BD43-0FC9B1931AF8', # Dell Power Manager Service
    'BDB50421-E961-42F3-B803-6DAC6F173834', # Dell Foundation Services
    '6250A087-31F9-47E2-A0EF-56ABF31B610E', # Dell Core Services
    '2F3E37A4-8F48-465A-813B-1F2964DBEB6A', # Dell Watchdog Timer	
    'E2CAA395-66B3-4772-85E3-6134DBAB244E', # Dell Protected Workspace
    'E9CD23E0-FC9B-4AE6-83A1-067FC62A39E7', # Dell Digital Delivery Services
    'D2E875B4-E71A-4AD2-9E0C-3E097A3D54FC', # Dell Command | Update for Windows Universal 4.8
    '9D377E41-9055-48E9-8109-59D777A78AAA', # Dell Core Services
    '286A9ADE-A581-43E8-AA85-6F5D58C7DC88', # Dell Optimizer Core
    'cf89b953-b6ce-48b6-9af6-03eb3bff3e2c', # Dell SupportAssist Remediation
    '21155715-548F-48D0-B5D1-3D030E8C22B3', # Dell Trusted Device Agent
    '691ecb5d-557a-41d2-b485-92352068d819' # Dell SupportAssist OS Recovery Plugin for Dell Update
)

# EXE-based uninstallers
$ExeUninstallers = @(
    @{ Path='C:\Program Files (x86)\InstallShield Installation Information\{286A9ADE-A581-43E8-AA85-6F5D58C7DC88}\DellOptimizer.exe'; Args='-remove -runfromtemp -silent'; Name='Dell Optimizer Service' },

    # SupportAssist Update Plugins
    @{ Path='C:\ProgramData\Package Cache\{819b927b-a8d8-46a9-9512-0326900f80e3}\DellUpdateSupportAssistPlugin.exe'; Args='/uninstall /quiet'; Name='SupportAssist Update Plugin (819b927b)' },
    @{ Path='C:\ProgramData\Package Cache\{31581d2d-a9e8-4f15-aa85-d6f9473b619e}\DellUpdateSupportAssistPlugin.exe'; Args='/uninstall /quiet'; Name='SupportAssist Update Plugin (31581d2d)' },
    @{ Path='C:\ProgramData\Package Cache\{9aec637d-a647-4f3b-998e-425f40e7dd50}\DellUpdateSupportAssistPlugin.exe'; Args='/uninstall /quiet'; Name='SupportAssist Update Plugin (9aec637d)' },
    @{ Path='C:\ProgramData\Package Cache\{3a267e2b-0948-4f12-a103-e2ac0461179d}\DellUpdateSupportAssistPlugin.exe'; Args='/uninstall /quiet'; Name='SupportAssist Update Plugin (3a267e2b)' },
    @{ Path='C:\ProgramData\Package Cache\{eb4d8dd7-ae4c-442d-8d21-8bfb73c03748}\DellUpdateSupportAssistPlugin.exe'; Args='/uninstall /quiet'; Name='SupportAssist Update Plugin (eb4d8dd7)' },
    @{ Path='C:\ProgramData\Package Cache\{ec40a028-983b-4213-af2c-77ed6f6fe1d5}\DellUpdateSupportAssistPlugin.exe'; Args='/uninstall /quiet'; Name='SupportAssist Update Plugin (ec40a028)' },
    @{ Path='C:\ProgramData\Package Cache\{e178914d-07c9-4d17-bd20-287c78ecc0f1}\DellUpdateSupportAssistPlugin.exe'; Args='/uninstall /quiet'; Name='SupportAssist Update Plugin (e178914d)' },
    @{ Path='C:\ProgramData\Package Cache\{b07a0d04-06d6-445c-ae24-7ae9991f11aa}\DellUpdateSupportAssistPlugin.exe'; Args='/uninstall /quiet'; Name='SupportAssist Update Plugin (b07a0d04)' },
    @{ Path='C:\ProgramData\Package Cache\{f6a4df94-48f2-459a-8d40-16b1fbed13c5}\DellUpdateSupportAssistPlugin.exe'; Args='/uninstall /quiet'; Name='SupportAssist Update Plugin (f6a4df94)' },

    # SupportAssist Remediation Services
    @{ Path='C:\ProgramData\Package Cache\{3c7a4bc1-7c12-40a9-be55-a4a2c1b415bd}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='SupportAssist Remediation (3c7a4bc1)' },
    @{ Path='C:\ProgramData\Package Cache\{5f9ca6e9-c7d9-49c9-88fa-196d35d8eb82}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='SupportAssist Remediation (5f9ca6e9)' },
    @{ Path='C:\ProgramData\Package Cache\{8ce1a5ae-856e-4b8e-a0e8-27dd7a209276}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='SupportAssist Remediation (8ce1a5ae)' },
    @{ Path='C:\ProgramData\Package Cache\{96846915-505c-49a2-8aa0-63f90927de87}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='SupportAssist Remediation (96846915)' },
    @{ Path='C:\ProgramData\Package Cache\{075ec656-5bd3-49b7-b0ee-07275a577c52}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='SupportAssist Remediation (075ec656)' },
    @{ Path='C:\ProgramData\Package Cache\{a0d5bbde-c013-48ba-b98a-ca0ff5cf36a6}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='SupportAssist Remediation (a0d5bbde)' },
    @{ Path='C:\ProgramData\Package Cache\{555298fa-14a9-48f2-a7a0-9602f31785da}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='SupportAssist Remediation (555298fa)' },
    @{ Path='C:\ProgramData\Package Cache\{34685541-a19e-4537-97c9-082238790346}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='SupportAssist Remediation (34685541)' },
    @{ Path='C:\ProgramData\Package Cache\{346eb8e9-af99-485f-b39d-89717cb78f11}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='SupportAssist Remediation (346eb8e9)' },
    @{ Path='C:\ProgramData\Package Cache\{db72dcd5-bf99-4888-b104-cb605b82ec8a}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='SupportAssist Remediation (db72dcd5)' },
    @{ Path='C:\ProgramData\Package Cache\{0b3f567c-a2ee-437a-861f-bb6da9f2111b}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='SupportAssist Remediation (0b3f567c)' },
    @{ Path='C:\ProgramData\Package Cache\{3563aa3a-c8ae-48d8-ab19-b1f359265295}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='SupportAssist Remediation (3563aa3a)' },

    # SupportAssist Agent & Others
    @{ Path='C:\Program Files\Dell\SupportAssistAgent\bin\SupportAssistUninstaller.exe'; Args='/S'; Name='Dell SupportAssist Agent' },
    @{ Path='C:\Program Files\Dell\Dell Peripheral Manager\Uninstall.exe'; Args='/S'; Name='Dell Peripheral Manager' },
    @{ Path='C:\Program Files\Dell\Dell Display Manager 2.0\uninst.exe'; Args='/S'; Name='Dell Display Manager 2.0' }
)
#endregion

# Ensure C:\Temp exists
New-Item -Path 'C:\Temp' -ItemType Directory -Force | Out-Null

Function Write-Log {
    Param([string]$Message)
    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))  $Message" |
      Out-File -FilePath $LogFile -Append -Encoding UTF8
}

Function Uninstall-MsiApp {
    Param([string]$ProductCode)
    $code = "{${ProductCode}}"
    Write-Log "Checking for MSI $code..."
    $key1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$ProductCode"
    $key2 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$ProductCode"
    if (Test-Path $key1 -or Test-Path $key2) {
        Write-Log "Found MSI $code, uninstalling..."
        try {
            $p = Start-Process msiexec.exe -ArgumentList "/x $code /qn /norestart" -Wait -NoNewWindow -PassThru
            if ($p.ExitCode -eq 0) { Write-Log "SUCCESS: MSI $code removed." } else { Write-Log "ERROR: MSI $code exit code $($p.ExitCode)" }
        } catch { Write-Log "EXCEPTION uninstalling MSI $code: $($_.Exception.Message)" }
    } else {
        Write-Log "Not installed: MSI $code"
    }
}

Function Uninstall-ExeApp {
    Param([string]$Path, [string]$Args, [string]$Name)
    if (Test-Path $Path) {
        Write-Log "Found EXE [$Name], uninstalling..."
        try {
            $p = Start-Process -FilePath $Path -ArgumentList $Args -Wait -NoNewWindow -PassThru
            if ($p.ExitCode -eq 0) { Write-Log "SUCCESS: $Name removed." } else { Write-Log "ERROR: $Name exit code $($p.ExitCode)" }
        } catch { Write-Log "EXCEPTION uninstalling EXE $Name: $($_.Exception.Message)" }
    } else {
        Write-Log "Not found: $Name at $Path"
    }
}

Function Uninstall-RegistryDellApps {
    Write-Log "=== Registry-driven uninstall pass ==="
    $roots = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    )
    foreach ($root in $roots) {
        Get-ChildItem $root -ErrorAction SilentlyContinue | ForEach-Object {
            try { $app = Get-ItemProperty $_.PSPath -ErrorAction Stop } catch { return }
            if ($app.DisplayName -like '*Dell*' -and $app.UninstallString) {
                $name = $app.DisplayName; $cmd = $app.UninstallString.Trim('"')
                Write-Log "Registry entry: $name"
                try {
                    if ($cmd -match 'msiexec') {
                        $args = ($cmd -replace '(^.*msiexec\.exe\s*)','') + ' /qn /norestart'
                        Start-Process msiexec.exe -ArgumentList $args -Wait -NoNewWindow
                    } else {
                        Start-Process cmd.exe -ArgumentList "/C `"$cmd /quiet`"" -Wait -NoNewWindow
                    }
                    Write-Log "Removed: $name"
                } catch { Write-Log "ERROR removing $name: $($_.Exception.Message)" }
            }
        }
    }
}

Function Clean-DellTasksAndServices {
    Write-Log "=== Removing Dell scheduled tasks ==="
    Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskPath -like '\Dell\*' -or $_.TaskName -like '*Dell*' } | ForEach-Object {
        Try { Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false; Write-Log "Task removed: $($_.TaskName)" } Catch { Write-Log "ERROR removing task $($_.TaskName): $($_.Exception.Message)" }
    }

    Write-Log "=== Stopping & deleting Dell services ==="
    Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'Dell*' -or $_.DisplayName -like '*Dell*' } | ForEach-Object {
        Try {
            Stop-Service -Name $_.Name -Force -ErrorAction SilentlyContinue
            Set-Service -Name $_.Name -StartupType Disabled
            sc.exe delete $_.Name | Out-Null
            Write-Log "Service deleted: $($_.Name)"
        } Catch { Write-Log "ERROR cleaning service $($_.Name): $($_.Exception.Message)" }
    }
}

# === Main Execution ===
Write-Log "=== Dell Bloatware removal START ==="
foreach ($guid in $DellGuids) { Uninstall-MsiApp -ProductCode $guid }
foreach ($entry in $ExeUninstallers) { Uninstall-ExeApp -Path $entry.Path -Args $entry.Args -Name $entry.Name }
Uninstall-RegistryDellApps
Clean-DellTasksAndServices
Write-Log "=== Dell Bloatware removal COMPLETE ==="
