# Indicators of Compromise (IoCs) — Campanha do Lab

> Documentado no fim do exercício: se um SOC recebesse esse tráfego,
> o que ele veria? Estas IoCs alimentam a fase de detecção do ciclo.

## Rede

| Tipo | Valor | Contexto |
|---|---|---|
| Domínio | `<DOMINIO DA CAMPANHA>` | entrega HTTPS (smuggling) |
| IP | `<IP PUBLICO EC2>` | web server + C2 callback |
| Porta C2 | 8443/TCP | reverse_tcp Meterpreter |
| Padrão | HTTP POST/SYN to :8443 periodic | beacon do Meterpreter (checkin) |

## Host (vítima)

| Tipo | Valor | Contexto |
|---|---|---|
| Arquivo | `Medidas_Paco_De_Lucia_Oficial_1971.pdf.iso` | download via smuggling |
| Arquivo | `Medidas_Paco_De_Lucia_Oficial_1971.exe` | loader |
| SHA256 | `<hash do exe>` | `sha256sum` do build |
| SHA256 | `<hash da iso>` | — |
| Processo | EXE sem console (WinMain) abrindo PDF | pai do processo shellcode |
| Comportamento | `VirtualAlloc → VirtualProtect(RX)` em user EXE | yara-rules possível |
| Conexão | processo de PDF/EXE → EC2:8443 | C2 |

## Detecções testadas

| Defesa | Detectou? | Assinatura |
|---|---|---|
| Microsoft Defender v1 | ✅ | `<mensagem exata>` |
| Microsoft Defender v2 | ⏳ | — |
| Chrome Safe Browsing | ✅ (v1, HTTP) | "arquivo perigoso" |

## Recomendações defensivas (o que bloquearia esta campanha)

- Block de downloads ISO/ZIP-cript via e-mail gateway
- MotW policy: alertar em executáveis de `<Intranet>` sem assinatura
- EDR: alerta em `VirtualProtect(PAGE_EXECUTE_READ)` pós-write em processo user
- DMARC/SPF no domínio da "empresa" do pretexto
