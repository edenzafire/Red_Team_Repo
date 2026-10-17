<#
.SYNOPSIS
  enum_windows.ps1 - Elite post-exploitation enumeration & triage (Windows)

.DESCRIPTION
  Collect + TRIAGE: emits findings.json with severity and next-action per check.
  PowerShell/.NET native only - no third-party binaries on the endpoint.
  OPSEC-aware: detects Script Block Logging / EDR agents and adapts collection.

  ATT&CK Enterprise: Discovery (TA0007), Credential Access (T1555/T1552),
  Privilege Escalation candidates (T1548/T1068/T1574).

.PARAMETER OutputDir
  Evidence directory (default: %TEMP%\enum_<UTC timestamp>)

.PARAMETER Quiet
  Suppress console progress output (OPSEC: no terminal noise)

.PARAMETER Checks
  Comma-separated subset of checks to run (e.g. "current_user,services_unquoted")

.PARAMETER Resume
  Skip checks whose output files already exist in OutputDir

.EXAMPLE
  PS> .\enum_windows.ps1 -Quiet -OutputDir C:\Windows\Temp\.cache_out

.NOTES
  Author: <your-name> | License: MIT
  Exit codes: 0 ok | 1 partial failure | 2 usage
#>
[CmdletBinding()]
param(
    [string]$OutputDir = (Join-Path $env:TEMP ("enum_" + (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ'))),
    [switch]$Quiet,
    [string]$Checks = '',
    [switch]$Resume
)

$ErrorActionPreference = 'SilentlyContinue'
$Ts       = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$Script:Fid = 0
$Script:Findings = New-Object System.Collections.Generic.List[string]
$Script:Ran = @{}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

# ==============================================================================
# Core machinery
# ==============================================================================
function Write-Log([string]$Msg) {
    if (-not $Quiet) { Write-Host "[*] $Msg" -ForegroundColor Cyan }
}

function Test-WantCheck([string]$Check) {
    if ([string]::IsNullOrWhiteSpace($Checks)) { return $true }
    return (",$Checks,").Contains(",$Check,")
}

function Get-Technique([string]$Check) {
    switch -Regex ($Check) {
        '^(system_info|patch_level|packages_audit)$'      { 'T1082' }
        '^(current_user|local_admins|local_users)$'       { 'T1087' }
        '^creds_files$'                                   { 'T1555' }
        '^(dpapi_candidates|wifi_profiles)$'              { 'T1552' }
        '^network_config$'                                { 'T1016' }
        '^listening_svcs$'                                { 'T1046' }
        '^arp_cache$'                                     { 'T1018' }
        '^services_unquoted$'                             { 'T1574.009' }
        '^writable_service_paths$'                        { 'T1574.011' }
        '^always_installelevated$'                        { 'T1548.002' }
        '^token_privileges$'                              { 'T1134' }
        '^scheduled_tasks$'                               { 'T1053.005' }
        '^defenses_state$'                                { 'T1562.001' }
        default                                           { 'T1082' }
    }
}

function Add-Finding([string]$Severity, [string]$Technique, [string]$Title, [string]$Next) {
    $Script:Fid++
    $o = [ordered]@{
        id        = ("F-04-{0:D2}" -f $Script:Fid)
        severity  = $Severity
        technique = $Technique
        title     = $Title
        next      = $Next
    }
    $Script:Findings.Add(($o | ConvertTo-Json -Compress))
}

function Save-Check([string]$Check, [scriptblock]$Block) {
    if (-not (Test-WantCheck $Check)) { return }
    if ($Resume -and $Script:Ran.ContainsKey($Check)) {
        Write-Log "Skip (resume): $Check"; return
    }
    if ($Script:Ran.ContainsKey($Check)) { return }

    Write-Log "Collecting: $Check"
    $outf = Join-Path $OutputDir "$Check.txt"
    $header = "### check=$Check host=$env:COMPUTERNAME ts=$Ts user=$env:USERNAME isAdmin=$([bool]([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))"
    $data = try { (& $Block) 2>&1 | Out-String } catch { "### error: $_" }
    Set-Content -Path $outf -Value "$header`n$data" -Encoding UTF8
    $Script:Ran[$Check] = $true

    [ordered]@{ check = $Check; technique = (Get-Technique $Check); file = "$Check.txt"; ts = $Ts } |
        ConvertTo-Json -Compress | Add-Content -Path (Join-Path $OutputDir 'manifest.jsonl')

    # triage hook
    $tri = Get-Command "triage_$Check" -ErrorAction SilentlyContinue
    if ($tri) { try { & $tri.FullName $outf } catch { } }
}

# ==============================================================================
# Environment awareness: who is watching? (log the decision, adapt behavior)
# ==============================================================================
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$EnvInfo = [ordered]@{
    ts         = $Ts
    isAdmin    = $IsAdmin
    os         = (Get-CimInstance Win32_OperatingSystem).Caption
    psVersion  = $PSVersionTable.PSVersion.ToString()
    monitored  = $false
    monitor_src = @()
}

# Script Block Logging active? -> PowerShell collection is high-signal
$sbl = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -ErrorAction SilentlyContinue
if ($sbl -and $sbl.EnableScriptBlockLogging -eq 1) {
    $EnvInfo.monitor_src += 'scriptblock_logging'
    $EnvInfo.monitored = $true
}
# AV / EDR agents in process space
$EdrProcs = 'MsMpEng|CrowdStrike|CSFalcon|Sentinel|CarbonBlack|Defender|Elastic|Sysmon|edr|xdr'
$procs = Get-Process | Where-Object { $_.ProcessName -match $EdrProcs } | Select-Object -ExpandProperty ProcessName -Unique
if ($procs) {
    $EnvInfo.monitor_src += $procs
    $EnvInfo.monitored = $true
}
# Sysmon service present?
$svcSysmon = Get-Service -Name 'Sysmon*' -ErrorAction SilentlyContinue
if ($svcSysmon) { $EnvInfo.monitor_src += 'sysmon_service'; $EnvInfo.monitored = $true }

$EnvInfo | ConvertTo-Json | Set-Content -Path (Join-Path $OutputDir 'environment.json') -Encoding UTF8

if ($EnvInfo.monitored -and -not $Quiet) {
    Write-Log "ATENCAO: monitoring detected ($($EnvInfo.monitor_src -join ', ')). PowerShell cmdlet names will land in Event 4104."
}

# ==============================================================================
# Embedded knowledge bases (offline triage)
# ==============================================================================
# Token privileges that directly enable escalation (well-known set)
$PrivEscPrivs = @(
    'SeDebugPrivilege',          # -> inject into SYSTEM process
    'SeBackupPrivilege',         # -> read SAM/SYSTEM, any file
    'SeRestorePrivilege',        # -> write anywhere
    'SeTakeOwnershipPrivilege',  # -> take ownership of SAM/services keys
    'SeLoadDriverPrivilege',     # -> load vulnerable driver
    'SeImpersonatePrivilege',    # -> potato family (if service account)
    'SeAssignPrimaryTokenPrivilege'
)

# AlwaysInstallElevated: both HKLM AND HKCU must be 1
# Unquoted service path: space in path + not quoted + writable segment -> T1574.009
# Writable service dir/binaries -> T1574.011

# ==============================================================================
# Triage analyzers - the "script that thinks"
# ==============================================================================
function triage_current_user([string]$File) {
    $raw = Get-Content $File -Raw
    # Token privilege triage
    foreach ($priv in $PrivEscPrivs) {
        if ($raw -match [regex]::Escape($priv)) {
            $next = switch -Regex ($priv) {
                'SeDebug|SeBackup|SeRestore|SeTakeOwnership' { 'dump SAM/SYSTEM via backup semantics or LSASS access (phase 05)' }
                'SeImpersonate|SeAssignPrimaryToken'          { 'potato family escalation - service account context confirmed' }
                'SeLoadDriver'                                { 'enumerate loadable vulnerable drivers (phase 05)' }
            }
            Add-Finding 'high' 'T1134' "$priv enabled for current user" $next
        }
    }
    # UAC / admin group membership
    if ($raw -match 'S-1-5-32-544' -or $raw -match 'Administrators') {
        Add-Finding 'medium' 'T1087' 'User is member of local Administrators group (UAC context applies)' 'check UAC level; high-integrity process?'
    }
}

function triage_always_installelevated([string]$File) {
    $raw = Get-Content $File -Raw
    if ($raw -match 'AlwaysInstallElevated\s*:\s*1') {
        Add-Finding 'critical' 'T1548.002' 'AlwaysInstallElevated enabled (HKLM and/or HKCU = 1)' 'msiexec /q /i payload.msi -> SYSTEM (verify BOTH hives = 1 first)'
    }
}

function triage_services_unquoted([string]$File) {
    $raw = Get-Content $File -Raw
    # each non-empty line with a path containing space, unquoted
    foreach ($line in ($raw -split "`n" | Where-Object { $_.Trim() })) {
        if ($line -match '([A-Za-z]:\\[^\r\n]*\s[^\r\n]*\.exe)' -and $line -notmatch '"') {
            $path = $Matches[1].Trim()
            Add-Finding 'high' 'T1574.009' "Unquoted service path: $path" "test writability of each path segment; place payload at first writable break"
        }
    }
}

function triage_writable_service_paths([string]$File) {
    $raw = Get-Content $File -Raw
    foreach ($line in ($raw -split "`n" | Where-Object { $_ -match 'WRITABLE' })) {
        Add-Finding 'high' 'T1574.011' ($line.Trim()) 'replace/implant service binary; restart service (needs start permission)'
    }
}

function triage_creds_files([string]$File) {
    $raw = Get-Content $File -Raw
    foreach ($line in ($raw -split "`n" | Where-Object { $_.Trim() -and $_ -match ':\s*\d+\s*:.*\w+' })) {
        $path = ($line -split ':')[0..1] -join ':'
        if ($path -match 'web\.config|appsettings|app\.config') {
            Add-Finding 'high' 'T1552.001' "Credential pattern in app config: $path" "read targeted lines only; validate format; do not exfil bulk"
        } else {
            Add-Finding 'medium' 'T1552.001' "Credential pattern match: $path" 'manual review'
        }
    }
}

function triage_wifi_profiles([string]$File) {
    $raw = Get-Content $File -Raw
    $n = ([regex]::Matches($raw, '(?m)^.*Profile\s*:\s*\S+')).Count
    if ($n -gt 0) {
        Add-Finding 'low' 'T1552' "$n WLAN profile(s) stored" "netsh wlan export profile key=clear reveals PSK (deferred; noisy)"
    }
}

function triage_defenses_state([string]$File) {
    $raw = Get-Content $File -Raw
    if ($raw -match 'RealTimeProtectionDisabled\s*:\s*True' -or $raw -match 'DisableRealtimeMonitoring\s*:\s*1') {
        Add-Finding 'info' 'T1562.001' 'Defender real-time protection disabled' 'execution freedom increased; document in OPSEC notes'
    }
}

function triage_local_users([string]$File) {
    $raw = Get-Content $File -Raw
    if ($raw -match '(?m)^\S+\s+(?:\d+)?\s+(?:Enabled|Disabled)') {
        # pass - informational; count only
        $n = ([regex]::Matches($raw, '(?m)^\S+')).Count
        Add-Finding 'info' 'T1087' "$n local accounts enumerated" 'cross-reference admin group membership in phase 06'
    }
}

function triage_scheduled_tasks([string]$File) {
    $raw = Get-Content $File -Raw
    if ($raw -match 'SYSTEM\s+\S+.*\.exe') {
        Add-Finding 'medium' 'T1053.005' 'Scheduled task running as SYSTEM found' 'check task action path writability (T1574 chain)'
    }
}

# ==============================================================================
# Collection checks
# ==============================================================================
Save-Check 'system_info' {
    Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture, LastBootUpTime | Format-List
    Get-CimInstance Win32_ComputerSystem  | Select-Object Manufacturer, Model, Domain | Format-List
}

Save-Check 'patch_level' {
    Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 15 HotFixID, InstalledOn
}

Save-Check 'current_user' {
    [Security.Principal.WindowsIdentity]::GetCurrent() | Select-Object Name, IsSystem, AuthenticationType | Format-List
    whoami /priv
    whoami /groups
}

Save-Check 'local_users' {
    # ADSI over `net user`: no 4799 noise
    ([ADSI]'WinNT://.,computer') | ForEach-Object { $_.children | Where-Object { $_.SchemaClassName -eq 'User' } | ForEach-Object { "$($_.Name)`t$($_.Description)" } }
}

Save-Check 'local_admins' {
    ([ADSI]'WinNT://./Administrators,group').Invoke('Members') | ForEach-Object {
        $_.GetType().InvokeMember('Name', 'GetProperty', $null, $_, $null)
    }
}

Save-Check 'creds_files' {
    # targeted Select-String: filenames only in output (-List), content never printed
    $roots = @($env:USERPROFILE, $env:ProgramFiles, 'C:\inetpub\wwwroot') | Where-Object { Test-Path $_ }
    foreach ($r in $roots) {
        Get-ChildItem -Path $r -Recurse -Depth 4 -Include *.config,*.xml,*.ini,*.yml,*.properties -ErrorAction SilentlyContinue |
            Select-String -Pattern 'password|apikey|secret|connectionString' -List |
            Select-Object -First 25 | ForEach-Object { "$($_.Path):$($_.LineNumber):MATCH" }
    }
}

Save-Check 'dpapi_candidates' {
    Get-ChildItem "$env:APPDATA\Microsoft\Protect","$env:LOCALAPPDATA\Microsoft\Credentials" -Recurse -ErrorAction SilentlyContinue | Select-Object FullName, Length
}

Save-Check 'wifi_profiles' {
    netsh wlan show profiles
}

Save-Check 'network_config' {
    Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway, DNSServer | Format-List
    Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Select-Object DestinationPrefix, NextHop, InterfaceAlias
}

Save-Check 'listening_svcs' {
    Get-NetTCPConnection -State Listen | Select-Object LocalAddress, LocalPort, OwningProcess | Sort-Object LocalPort
}

Save-Check 'arp_cache' {
    Get-NetNeighbor -State Reachable | Select-Object IPAddress, LinkLayerAddress, InterfaceAlias
}

Save-Check 'services_unquoted' {
    Get-CimInstance Win32_Service |
        Where-Object { $_.PathName -and $_.PathName -notmatch '"' -and $_.PathName -match '\s[A-Za-z]:\\|\\\s' -and $_.PathName -match '\s' } |
        Select-Object Name, PathName, StartMode, StartName | Format-List
}

Save-Check 'writable_service_paths' {
    # for each service binary path, test writability of each segment (admin-only value if not admin; still logged)
    Get-CimInstance Win32_Service | Where-Object { $_.PathName } | ForEach-Object {
        $svc = $_.Name; $raw = ($_.PathName -replace '^"([^"]+)"', '$1') -replace '\s+[-/].*$', ''
        if (Test-Path $raw) {
            $dir = Split-Path $raw
            try {
                $test = Join-Path $dir ([guid]::NewGuid().ToString())
                [IO.File]::WriteAllText($test, 'x')
                Remove-Item $test -Force
                "WRITABLE service=$svc dir=$dir bin=$raw"
            } catch { }
        }
    }
}

Save-Check 'always_installelevated' {
    foreach ($hive in 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer','HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer') {
        $v = (Get-ItemProperty $hive -ErrorAction SilentlyContinue).AlwaysInstallElevated
        "${hive} : AlwaysInstallElevated = $v"
    }
}

Save-Check 'token_privileges' {
    whoami /priv
}

Save-Check 'scheduled_tasks' {
    # filter: only SYSTEM/high-integrity tasks with .exe actions
    Get-ScheduledTask | Where-Object { $_.State -ne 'Disabled' } | ForEach-Object {
        $a = ($_.Actions | Where-Object { $_.Execute })[0]
        if ($a) { "$($_.Principal.UserId)`t$($_.TaskName)`t$($a.Execute) $($a.Arguments)" }
    }
}

Save-Check 'defenses_state' {
    Get-MpComputerStatus 2>$null | Select-Object AMServiceEnabled, RealTimeProtectionEnabled, AntivirusEnabled | Format-List
    Get-Service WinDefend, Sysmon* -ErrorAction SilentlyContinue | Select-Object Name, Status, StartType
}

# ==============================================================================
# Finalize: findings.json (single source of truth, same schema as Linux variant)
# ==============================================================================
$summary = [ordered]@{
    generated = $Ts
    host      = $env:COMPUTERNAME
    isAdmin   = $IsAdmin
    monitored = $EnvInfo.monitored
    stealth   = ($EnvInfo.monitored)   # auto-adapt flag documented, mirrors Linux behavior
    findings  = $Script:Findings | ForEach-Object { $_ | ConvertFrom-Json }
}
$summary | ConvertTo-Json -Depth 4 | Set-Content -Path (Join-Path $OutputDir 'findings.json') -Encoding UTF8

# self-audit: artifacts left on host
@("enum_windows.ps1 (this script)", $OutputDir) |
    Set-Content -Path (Join-Path $OutputDir 'cleanup_manifest.txt') -Encoding UTF8

Write-Log "Done. $($Script:Ran.Count) checks, $($Script:Fid) findings -> $(Join-Path $OutputDir 'findings.json')"
exit 0
