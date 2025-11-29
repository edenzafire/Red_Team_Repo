# 01 – Registro de OPSEC da Sessão
Projeto: Auto-OSINT – Dark Web Recon  
Alvo: Perfil fictício – Yuri Kirichenko  
Data: 2025-11-28  
Sistema: Debian Trixie (usuário: kirichenko)

---

## 1. Conexão VPN
**Status:** Ativa no momento da checagem  
**Comando executado:**

curl ifconfig.me


Retorno obtido:
2a02:6ea0:5601:6308::11

## Interpretação:

Endereço público em IPv6.

Origem compatível com saída de VPN — OK para navegação antes do Tor.

Confirma que o sistema não está expondo IP residencial nem IPv4 real.

## 2.  Regras de OPSEC ativas

Ambiente usado: usuário isolado (kirichenko) no Debian Trixie.

VPN → Tor (fluxo recomendado, “Tor over VPN”).

Nenhuma conta pessoal logada.

Nenhum serviço claro utilizado durante sessão.

JavaScript será desativado no Tor Browser (modo Safest).

Downloads desabilitados.

Capturas de tela serão borradas antes de qualquer publicação.


