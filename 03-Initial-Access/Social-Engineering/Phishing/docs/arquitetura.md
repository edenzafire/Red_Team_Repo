
# Arquitetura da Infraestrutura
```
                      ┌──────────────────────────────┐
                      │        AWS EC2 (C2/Web)      │
                      │  Ubuntu 24.04 · t2.micro     │
                      │  Nginx + TLS (Let's Encrypt) │
                      │  /var/www/phishing/index.html│
                      │  handler Meterpreter :8443   │
                      │        (screen -S c2)        │
                      └────────▲─────────△─────────-─┘
                HTTPS entrega  │         │  callback reverse_tcp
                               │         │  (payload → 8443)
  ┌────────────────────────────┴───┐ ┌──-┴─────────────────────────┐
  │ DEBIAN 12 (atacante)           │ │ WIN 10 (vítima do laboratório) │ 
  │ QEMU/KVM no host Ubuntu 24.04  │ │ Chrome/Edge → phishing      │ 
  │ build.sh · lab_up.sh           │ │ ISO montada → EXE run       │ 
  │ msfvenom · mingw-w64           │ │ Defender ON (teste real)    │  
  │ redteam-lab.pem (SSH AWS)      │ │                             │
  └────────────┬───────────────────┘ └─────────────────────────────┘
     scp/ssh (gerencia EC2)         ▼        E-mail do laboratório  → link https://docs.DOMINIO/?id=vitima_NN

```
## Componentes

| Componente | Papel | Notas |
|---|---|---|
| EC2 + Nginx | Hospeda página de smuggling via HTTPS | TLS remove warning do Chrome |
| EC2 :8443 | C2 (handler Meterpreter) | porta não-padrão, SG liberado |
| DNS A @ / docs | Aponta para IP dinâmico da EC2 | TTL 300-600 (troca a cada sessão) |
| build.sh | Pipeline completo local (payload→ISO→HTML) | seed compartilhada Python↔C++ |
| lab_up.sh | Ciclo de sessão: recompile + deploy | pede IP da EC2 via read |
| cliques.log | Rastreamento por vítima (?id=NN) | evidência para o relatório |

## Ciclo de sessão de estudo (custo zero)

1. Start da EC2 → anotar IP público
2. Atualizar registros A no DNS (GoDaddy)
3. `./lab_up.sh DOMINIO` (recompila com IP novo + sobe página)
4. SSH na EC2 → `screen -r c2` (ou subir handler novo)
5. Teste na vítima → coletar resultados em `docs/resultados.md`
6. Stop da EC2 (sem Elastic IP = sem custo parado)

## Segurança da própria infra

- `.pem` com `chmod 400`, nunca no repo (`.gitignore`)
- SG: SSH 22 restrito ao IP de casa; 8443 pode fechar após o teste
- `fail2ban` + `ufw` instalados pelo `setup_server.sh`


