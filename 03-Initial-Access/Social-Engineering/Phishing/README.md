
# 03_Initial Access — Phishing Campaign (Lab)

Exercício autorizado de ciclo completo de ataque: initial access via
phishing com HTML smuggling, entrega via infraestrutura cloud (AWS EC2 +
TLS), payload customizado com loader in-memory.

> **Escopo**: ambiente 100% laboratorial — VMs próprias em rede isolada.
> Nenhum alvo real foi utilizado.

### Estrutura do Repositório 
```
03_Initial-Access_Phishing/
├── README.md                    # visão geral, pretexto, fluxo, resultados
├── .gitignore                   # CRÍTICO
├── docs/
│   ├── arquitetura.md           # diagrama da infra (Debian → EC2 → vítima)
│   ├── metodologia.md           # MITRE ATT&CK mapping (T1566, T1204, etc.)
│   └── resultados.md            # o que funcionou, o que o Defender pegou, IoCs
├── infrastructure/
│   ├── setup_server.sh          # provisionamento da EC2 (nginx + certbot)
│   ├── lab_up.sh                # ciclo de sessão (DNS + recompile + deploy)
│   └── handler.md               # como subir o listener (comandos msfconsole)
├── payload/
│   ├── encrypt2.py              # criptografia rolling XOR + FNV
│   ├── veneno2.cpp              # loader
│   ├── recurso.rc               # recursos (ícone + versioninfo)
│   └── build.sh                 # pipeline de compilação
├── delivery/
│   ├── generate_smuggling.py    # HTML smuggling generator
│   ├── template.html            # template da página (sem base64)
│   └── phishing_email.md        # corpo do e-mail da campanha (pretexto)
└── report/
    └── IOC.md                   # hashes, domínios, IPs, assinatura de detecção
```
## Metodologia (MITRE ATT&CK)

| Tática | Técnica | ID |
|---|---|---|
| Initial Access | Phishing: Spear phishing Link | T1566.002 |
| Execution | User Execution: Malicious File | T1204.002 |
| Defense Evasion | HTML Smuggling | T1226.001* |
| Command & Control | Application Layer Protocol | T1071 |

## Pipeline
```
msfvenom (staged reverse_tcp) │ encrypt2.py ── rolling XOR + chave derivada FNV-1a (runtime) │ veneno2.cpp ── loader C++ (resource load, RW→RX, callback exec) │ build.sh ── EXE c/ ícone+metadados → ISO (MOTW bypass) │ generate_smuggling.py ── contrabando de HTML (base64 incorporado) │ AWS EC2 + Nginx + Let's Encrypt ── entrega HTTPS rastreável
```
## Resultados

| Teste | Defender | Resultado |
|---|---|---|
| v1 (XOR fixo + CreateThread) | ✅ detectado | assinatura estática |
| v2 (rolling XOR + resource + callback) | 🔴 pendente | em teste |

Detalhes em [docs/resultados.md](docs/resultados.md)



