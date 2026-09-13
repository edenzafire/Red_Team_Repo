# 🖥️ Lab Prep — Preparação de VM Vítima Windows 10

Script PowerShell para automatizar a preparação de uma **máquina virtual Windows 10** destinada a laboratórios de **offensive security, pós-exploração e detecção**. O script "suja" a VM para que ela se pareça com uma estação de trabalho corporativa real, com usuários, arquivos e configurações comuns encontradas em ambientes de rede.

> ⚠️ **AVISO — USO EXCLUSIVO EM LABORATÓRIO**
> Este script cria **credenciais em texto claro** e **configurações deliberadamente vulneráveis** (share aberto, unquoted service path, RDP habilitado). **NUNCA execute em uma máquina pessoal ou corporativa real.** Use apenas em VMs isoladas (VirtualBox, VMware, Hyper-V) sem acesso à rede de produção. O autor não se responsabiliza por uso indevido.

---

## 📋 Pré-requisitos

- Windows 10 (VM isolada — VirtualBox, VMware, Hyper-V)
- PowerShell 5.1+ (padrão do Windows 10)
- Executar como **Administrador**
- Snapshot da VM **antes** de executar (recomendado!)

---

## 🚀 Passo a Passo de Utilização

### 1. Clone o repositório na VM

```powershell
git clone https://github.com/SEU_USUARIO/lab-prep.git
cd lab-prep
```

*(Alternativa sem git: baixe o ZIP pelo GitHub e extraia na VM.)*

### 2. Tire um snapshot da VM

No hipervisor (VirtualBox/VMware/Hyper-V), crie um snapshot. Assim você pode reverter a qualquer momento.

### 3. (Opcional) Edite a configuração

Abra o `config.json` e ajuste:

- `users` — nomes, senhas e quem será administrador
- `enable_rdp` / `create_smb_share` / `create_scheduled_task` — liga/desliga cada vetor

```json
{
  "users": [
    { "name": "joao.silva", "pass": "Tr@balho2023!", "admin": false }
  ]
}
```

### 4. Execute o script como Administrador

Abra o **PowerShell como Administrador** (Win+X → "Windows PowerShell (Admin)") e rode:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\dirty-lab.ps1
```

Se o hostname da VM **não** contiver "LAB", "VICTIM", "VM" ou "TESTE", o script pedirá confirmação. Para pular essa checagem:

```powershell
.\dirty-lab.ps1 -Force
```

### 5. Gere artefatos de uso real (recomendado)

Faça logon/logout com alguns usuários criados e movimente arquivos. Isso gera NTUSER.DAT, arquivos Recent, prefetch e logs — deixando a máquina ainda mais realista para treinos de forense/enumeração.

### 6. Verifique o resultado

```powershell
# Usuarios criados
net user
Get-LocalUser | Select Name, Enabled

# Arquivos decoy
Get-ChildItem C:\Users\Public, C:\Users\*\Documents, C:\Users\*\Desktop -File -Recurse -ErrorAction SilentlyContinue

# Tarefa agendada
Get-ScheduledTask -TaskName "BackupDiario"

# Compartilhamento SMB
Get-SmbShare

# Servico com unquoted path (alvo classico de privesc)
wmic service get name,pathname | findstr /v "system32"

# RDP
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections
```

### 7. (Opcional) Reverta tudo

Restaure o snapshot tirado no passo 2 — ou desfaça manualmente:

```powershell
# Remove usuarios (exceto os nativos)
"joao.silva","maria.oliveira","ti.admin","financeiro","recepcao","backup_user" |
  ForEach-Object { Remove-LocalUser -Name $_ -ErrorAction SilentlyContinue }

# Remove share e tarefa
Remove-SmbShare -Name "Compartilhado" -Force -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName "BackupDiario" -Confirm:$false -ErrorAction SilentlyContinue

# Remove servico
Stop-Service MeuServicoApp -ErrorAction SilentlyContinue
sc.exe delete MeuServicoApp
```

---

## 🎯 O que o script cria

| Item | Propósito didático |
|------|--------------------|
| 6 usuários locais (1 admin) | Enumeração, password spraying, privesc |
| 4 arquivos com senhas em texto claro | Prática de credential hunting (findstr, grep) |
| Planilhas/relatórios fictícios | Realismo forense |
| Tarefa agendada "BackupDiario" | Persistence, abused scheduled tasks |
| Share SMB "Compartilhado" (Everyone) | Enumeração de rede, lateral movement |
| Serviço com unquoted path | Escalação de privilégio clássica |
| RDP habilitado | Movimento lateral, brute force lab |

## 🎓 Cenários de treino sugeridos

- Enumeração local (`whoami /priv`, `net user`, PowerView)
- Credential hunting (findstr, SharpHound, manual)
- Escalação via unquoted service path
- Movimento lateral via SMB/RDP
- Blue team: gerar telemetria e escrever detecções (Sysmon, Event IDs)

---

## 📄 Licença

MIT — veja [LICENSE](LICENSE).
