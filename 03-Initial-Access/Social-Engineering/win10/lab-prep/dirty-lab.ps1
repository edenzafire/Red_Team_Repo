<#
.SYNOPSIS
    dirty-lab.ps1 - Preparacao de VM vitima Windows 10 para laboratorio de
    offensive security / deteccao.

.DESCRIPTION
    Cria usuarios ficticios, arquivos com credenciais decoy, documentos de
    "trabalho", tarefa agendada, compartilhamento SMB, servico com unquoted
    path e habilita RDP - simulando uma estacao de trabalho corporativa real.

    USO EXCLUSIVO EM VMs DE LABORATORIO ISOLADO.

.EXAMPLE
    .\dirty-lab.ps1 -ConfigPath .\config.json
    .\dirty-lab.ps1 -ConfigPath .\config.json -Force
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = "$PSScriptRoot\config.json",
    [switch]$Force   # pula a confirmacao de seguranca
)

# ============================================================
# 0. Check de seguranca - garantir que estamos em uma VM de lab
# ============================================================
if (-not $Force) {
    if ($env:COMPUTERNAME -notmatch (Get-Content $ConfigPath | ConvertFrom-Json).lab_name_match) {
        Write-Warning "Hostname '$($env:COMPUTERNAME)' nao parece ser uma VM de laboratorio."
        $resp = Read-Host "Este script cria credenciais em texto claro. Continuar mesmo assim? (s/N)"
        if ($resp -ne "s") { Write-Host "Abortado pelo usuario." -ForegroundColor Yellow; exit 1 }
    }
}

# Verifica elevacao
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
           ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Execute este script como Administrador."
    exit 1
}

# Carrega configuracao
$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
Write-Host "`n[*] Config carregada de: $ConfigPath" -ForegroundColor Cyan

# ============================================================
# 1. Criacao de usuarios ficticios
# ============================================================
function New-LabUsers {
    param([PSCustomObject]$Users)

    Write-Host "`n=== [1] Criando usuarios locais ===" -ForegroundColor Cyan
    foreach ($u in $Users) {
        if (Get-LocalUser -Name $u.name -ErrorAction SilentlyContinue) {
            Write-Host "[=] Usuario ja existe: $($u.name)" -ForegroundColor DarkGray
            continue
        }
        New-LocalUser -Name $u.name `
            -Password (ConvertTo-SecureString $u.pass -AsPlainText -Force) `
            -FullName $u.name -Description "Usuario de laboratorio" `
            -PasswordNeverExpires | Out-Null

        if ($u.admin) {
            Add-LocalGroupMember -Group "Administrators" -Member $u.name -ErrorAction SilentlyContinue
        }
        Write-Host "[+] Criado: $($u.name) $(if($u.admin){'(Administrador)'})"
    }
}

# ============================================================
# 2. Arquivos decoy com credenciais em texto claro
# ============================================================
function New-DecoyCredentials {
    param([PSCustomObject]$Users)

    Write-Host "`n=== [2] Criando arquivos de credenciais decoy ===" -ForegroundColor Cyan

    $user1 = $Users[0]; $user2 = $Users[1]
    $userFin = $Users | Where-Object { $_.name -eq "financeiro" }
    $userBkp = $Users | Where-Object { $_.name -eq "backup_user" }

    $credFiles = @{
        "C:\Users\Public\senhas.txt" =
            "Senhas do setor:`r`n$($user1.name):$($user1.pass)`r`n$($user2.name):$($user2.pass)"
        "C:\Users\$($user1.name)\Documents\anotacoes.txt" =
            "lembrar de trocar a senha do email: $($user1.name):$($user1.pass)"
        "C:\Users\$($userFin.name)\Desktop\acessos.txt" =
            "portal financeiro`r`nlogin: $($userFin.name)`r`nsenha: $($userFin.pass)"
        "C:\Users\$($userBkp.name)\Documents\credenciais_backup.txt" =
            "$($userBkp.name):$($userBkp.pass)`r`nserver01:Backup@Server01"
    }

    foreach ($path in $credFiles.Keys) {
        $dir = Split-Path $path
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Set-Content -Path $path -Value $credFiles[$path] -Encoding UTF8
        Write-Host "[+] $path"
    }
}

# ============================================================
# 3. Arquivos de "trabalho" - sujar a maquina
# ============================================================
function New-FakeWorkFiles {
    param([PSCustomObject]$Users)
    $user1 = $Users[0]

    Write-Host "`n=== [3] Criando arquivos de trabalho ficticios ===" -ForegroundColor Cyan
    1..5 | ForEach-Object {
        Set-Content "C:\Users\Public\Desktop\relatorio_vendas_202$_.txt" ("Dados ficticios " * 50)
        Set-Content "C:\Users\$($user1.name)\Documents\planilha_fornecedores_$_.csv" `
            "id,nome,valor`n$_,Fornecedor $_,$($_)00.00"
    }
    Write-Host "[+] 10 arquivos criados (Desktop/Public + Documents)"
}

# ============================================================
# 4. Vetores classicos: tarefa agendada, SMB, unquoted path, RDP
# ============================================================
function Set-LabVectors {
    param([PSCustomObject]$Config)
    $user1 = $Config.users[0]

    if ($Config.create_scheduled_task) {
        Write-Host "`n=== [4] Tarefa agendada (persistence lab) ===" -ForegroundColor Cyan
        $action = New-ScheduledTaskAction -Execute "cmd.exe" `
            -Argument "/c robocopy C:\Users\$($user1.name)\Documents D:\Backup /E /LOG:C:\backup.log"
        Register-ScheduledTask -TaskName "BackupDiario" -Action $action `
            -Trigger (New-ScheduledTaskTrigger -Daily -At 22:00) -Force | Out-Null
        Write-Host "[+] Tarefa 'BackupDiario' registrada"
    }

    if ($Config.create_smb_share) {
        Write-Host "`n=== [5] Compartilhamento SMB ===" -ForegroundColor Cyan
        New-SmbShare -Name "Compartilhado" -Path "C:\Users\Public" -FullAccess "Everyone" `
            -ErrorAction SilentlyContinue | Out-Null
        Write-Host "[+] Share '\\$($env:COMPUTERNAME)\Compartilhado' criado"
    }

    Write-Host "`n=== [6] Servico com unquoted path (privesc lab) ===" -ForegroundColor Cyan
    if (-not (Get-Service -Name "MeuServicoApp" -ErrorAction SilentlyContinue)) {
        New-Item -ItemType Directory -Path "C:\Program Files\App Util" -Force | Out-Null
        Set-Content "C:\Program Files\App Util\service.exe" "# placeholder" -ErrorAction SilentlyContinue
        New-Service -Name "MeuServicoApp" `
            -BinaryPathName "C:\Program Files\App Util\service.exe -k run" `
            -DisplayName "App de Utilitarios" -StartupType Automatic -ErrorAction SilentlyContinue | Out-Null
        Write-Host "[+] Servico 'MeuServicoApp' criado com unquoted path"
    } else {
        Write-Host "[=] Servico ja existe" -ForegroundColor DarkGray
    }

    if ($Config.enable_rdp) {
        Write-Host "`n=== [7] Habilitando RDP ===" -ForegroundColor Cyan
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0
        Enable-NetFirewallRule -DisplayGroup "*Area de Trabalho Remota*" -ErrorAction SilentlyContinue
        Enable-NetFirewallRule -DisplayGroup "*Remote Desktop*" -ErrorAction SilentlyContinue
        Write-Host "[+] RDP habilitado"
    }
}

# ============================================================
# EXECUCAO
# ============================================================
New-LabUsers         -Users $config.users
New-DecoyCredentials -Users $config.users
New-FakeWorkFiles    -Users $config.users
Set-LabVectors       -Config $config

Write-Host "`n[OK] Laboratorio preparado com sucesso!" -ForegroundColor Green
Write-Host "Dica: faca logon/logout com alguns usuarios para gerar NTUSER, prefetch e artefatos de uso real."
