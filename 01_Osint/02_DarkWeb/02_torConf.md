# ⚙️ Network Validation: Tor Proxy & Routing Configuration

![Category: Infrastructure Validation](https://img.shields.io/badge/Category-Infra_Validation-blue?style=for-the-badge)
![Status: Verified](https://img.shields.io/badge/Status-Verified_Ready-brightgreen?style=for-the-badge)
![Security: SOCKS5_Tunnel](https://img.shields.io/badge/Security-SOCKS5_Tunnel-purple?style=for-the-badge)

Analista: Eden Zafire
Data da Validação: 2025-11-28
Sistema: Debian Trixie
Objetivo: Validar funcionamento da rede Tor para início da fase OSINT Dark Web

📌 1. Verificação do Serviço Tor
🔎 Comando:

systemctl status tor


✔️ Resultado:

    Serviço tor.service carregado.

    Status inicial: inactive (dead).

📌 2. Ativação manual da instância Tor correta
🔎 Comandos executados:
sudo systemctl start tor@default
sudo systemctl enable tor@default
systemctl status tor@default

✔️ Resultado:

Serviço ativo e rodando.

Instância correta: tor@default.service

Porta local SOCKS5: 9050

PID ativo: 13307

Memória: 141 MB

Uptime no momento da coleta: ~2min

📌 3. Teste de conectividade da porta Tor (9050)
🔎 Comando:

ss -tlpn | grep 9050


✔️ Resultado:

LISTEN 0 4096 127.0.0.1:9050 0.0.0.0:* 

A porta Tor está aberta e aceitando conexões locais.

📌 4. Teste de IP via Tor
🔎 Comando:

curl --socks5-hostname localhost:9050 https://checkip.amazonaws.com

✔️ Resultado:
91.208.75.178

📌 Interpretação:

IP completamente diferente do IP real do analista.

IP localizado em país europeu (nó de saída Tor).

Sessão Tor validada e funcionando corretamente.

🧪 5. Checklist de Segurança – Antes da Dark Web


Item	                   Status

Tor ativo                   ✔️
Porta SOCKS5 validada       ✔️
IP roteado pelo Tor         ✔️
VPN ativa                   ✔️
Navegador Tor aberto        ✔️
Modo forense ativado        ✔️
Pasta do projeto configurada✔️

📌 6. Conclusão

A sessão Tor está funcionando corretamente e o tráfego do sistema Debian está apto para:

acesso seguro a domínios .onion

coleta OSINT em fóruns e motores de busca da Dark Web

captura de evidências sem expor IP ou fingerprint real

O ambiente encontra-se pronto para avançar para a próxima etapa da investigação.



















