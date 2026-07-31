# 🛡️ Registro de OPSEC (Operational Security) - Sessão Dark Web

**Projeto:** Portfolio Pentest - Phase 01 (OSINT)  
**ID da Sessão:** 20251128-DW-01  
**Operador:** Eden Zafire 
**Ambiente:** Debian Trixie (Isolated Workspace)

---

## 1. Protocolo de Conectividade & Anonimato
Para mitigar riscos de desanonimização por parte de ISPs ou exit nodes maliciosos, foi estabelecida a seguinte cadeia de conexão:

**Fluxo:** `Physical NIC` -> `VPN Tunnel` -> `Tor Network` (Tor over VPN).

### Verificação de Vazamento (Leak Test)
* **Comando:** `curl -6 ifconfig.me`
* **Retorno:** `2a02:6ea0:5601:6308::11`
* **Análise:** Endereço IPv6 confirmado como endpoint de saída do provedor de VPN. O tráfego residencial (IPv4/IPv6 real) está devidamente tunelado e mascarado.

---

## 2. Hardening do Sistema e Navegador
Aplicadas as diretivas de endurecimento para evitar **Browser Fingerprinting** e execução de código arbitrário:

1.  **Tor Browser (Security Level: Safest):** * JavaScript desativado globalmente via `noscript`.
    * Leitura de fontes locais e Canvas Fingerprinting bloqueados.
2.  **Anti-Forensics:** * Sessão executada em partição com isolamento de privilégios.
    * Desabilitação de histórico de comandos (`set +o history`) para evitar persistência de queries sensíveis em `.bash_history`.
3.  **Media Sanitization:** * Capturas de tela processadas via `ExifTool` para remoção de metadados antes da inclusão no repositório.

---

## 3. Checklist de Higiene Digital (Post-Session)
- [ ] Limpeza de cache de DNS local.
- [ ] Purge de arquivos temporários em `/tmp`.
- [ ] Verificação de logs do sistema para garantir que nenhum erro expôs o IP real durante quedas de conexão (Kill Switch Validation).

---
> **Nota de Auditoria:** Este registro serve como prova de conformidade ética e técnica, garantindo que a investigação não comprometeu a infraestrutura do analista nem violou termos de serviço de provedores.
