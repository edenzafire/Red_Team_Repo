# Relatório Técnico de Enumeração e Vulnerabilidades Críticas
## Alvo 03 – Metasploitable 2 (Serviços Legados)

**Author:** Zafire Daniel / Nikolay (Lab Environment)  
**Data:** 28 de Fevereiro de 2026  
**MITRE ATT&CK:** T1046, T1595.002, T1210  
**Status:** Concluído  
**Ambiente:** Rede Interna (Identificado via Pivoting)

---

# 1. Executive Summary

Este relatório detalha a enumeração do host **METASPLOITABLE-02**, identificado na rede interna. O sistema opera com uma versão obsoleta do Linux (Ubuntu 8.04) e foi configurado com múltiplos serviços propositalmente vulneráveis.

A análise técnica revelou:
- **Exposição Extrema:** Múltiplas portas abertas com serviços sem patches.
- **Backdoor Crítico:** Confirmação de backdoor no serviço FTP (vsftpd 2.3.4).
- **Vetor de Comprometimento Instantâneo:** Possibilidade de obtenção de privilégios de **ROOT** sem necessidade de credenciais.

O risco associado a este ativo é **Catastrófico**, representando uma vulnerabilidade sistêmica para toda a infraestrutura interna.

---
> [!NOTE]
> **Nota de Escopo Técnica:** Embora o alvo **Metasploitable 2** apresente uma superfície de ataque extremamente vasta, com dezenas de serviços obsoletos e vulneráveis por design, este relatório foca deliberadamente nas vulnerabilidades de **FTP (vsftpd 2.3.4)** e **Enumeração de Serviços Críticos**. Esta escolha estratégica para o portfólio visa demonstrar a capacidade de identificar vetores de **RCE (Remote Code Execution)** imediato e backdoors de alto impacto, que são cruciais em cenários de movimentação lateral e elevação de privilégios. O objetivo é evidenciar a análise crítica sobre a severidade dos riscos, priorizando falhas que permitem o comprometimento total do sistema (**Root**) em detrimento de vulnerabilidades de menor relevância técnica para este estudo de caso.
---

# 2. Escopo

**Host Alvo:**
- **Hostname:** METASPLOITABLE-02
- **IP:** 192.168.x.w
- **OS:** Linux (Ubuntu 8.04 - Kernel 2.6.x)
- **Contexto:** Servidor de serviços legados e banco de dados.

**Objetivo:**
Mapear vulnerabilidades exploráveis em serviços de rede para demonstrar o risco de manter sistemas sem suporte (End-of-Life) na rede corporativa.

---

# 3. Metodologia

A análise seguiu as fases do **MITRE ATT&CK**:
1.  **Reconhecimento Ativo:** Varredura completa de portas (65535 TCP).
2.  **Fingerprinting de Versão:** Identificação de softwares e versões obsoletas.
3.  **Vulnerability Validation:** Uso de scripts NSE (Nmap Scripting Engine) para confirmar backdoors conhecidos.

---

# 4. Timeline Técnica

* **T+02:10** – Início da varredura exaustiva de todas as portas TCP.
* **T+02:25** – Identificação de banners de serviços críticos (FTP, Telnet, Ingreslock).
* **T+02:40** – Execução de scripts NSE direcionados à porta 21.
* **T+02:50** – Confirmação de vulnerabilidade de execução remota de comandos via Backdoor.

---

# 5. Descobertas Técnicas

## 5.1 Varredura de Serviços e Versões (Full Scan)

### Técnica MITRE
**T1595.002** – Active Scanning: Vulnerability Scanning

### Comando Executado
```bash
nmap -sV -p- -T4 192.168.x.w -oN ./evidencias/meta2/nmap_full.txt
```
### Análise
O host expõe uma superfície de ataque anormalmente vasta. Portas como **21 (FTP)**, **23 (Telnet)** e **1524 (Ingreslock)** estão ativas. A ausência de um firewall host-based (iptables) permite o mapeamento completo e irrestrito da infraestrutura de rede do alvo.

---

### 5.2 Enumeração de FTP e Backdoor vsftpd

**Técnica MITRE:** T1210 – Exploitation of Remote Services

**Comando Executado:**
```bash
nmap -sV --script ftp-anon,ftp-vsftpd-backdoor -p 21 192.168.x.w
```

### Análise Técnica
O serviço **vsftpd 2.3.4** identificado contém um **backdoor histórico**. O gatilho para a vulnerabilidade ocorre durante a autenticação: quando um nome de usuário enviado termina com a sequência de caracteres `:)`, o serviço aciona automaticamente a abertura de um *bind shell* na porta **6200/TCP**.

* **Impacto:** Permite acesso imediato com privilégios de **ROOT** (superusuário), contornando completamente qualquer mecanismo de autenticação, política de senhas ou controle de acesso local.
---
## 6. Análise de Risco

> [!CAUTION]
> **Impacto no Negócio:** A presença deste ativo em rede é equivalente a uma porta aberta para o núcleo da infraestrutura. Um invasor pode utilizar este host para armazenar ferramentas de ataque (C2), realizar **pivoting** para outros servidores críticos ou destruir logs de auditoria em segundos. O impacto é classificado como **Perda Total de Controle Operacional**.

---

## 7. Recomendações de Mitigação

### 7.1 Remediação Imediata
* **Desativação:** O sistema deve ser desconectado da rede imediatamente. Devido à obsolescência crítica do kernel e dos serviços, não existem patches de segurança modernos para mitigar os riscos.
* **Substituição:** Migrar as funções e serviços essenciais para uma distribuição Linux atualizada e com suporte de segurança ativo (Ex: **Debian 12** ou **Ubuntu 24.04 LTS**).

### 7.2 Defesa (Blue Team Perspective)
* **Isolamento (Sandboxing):** Caso o sistema seja estritamente necessário para operações legadas, ele deve ser isolado em uma **VLAN estrita**, sem qualquer acesso à internet e protegida por regras de firewall "Deny All" por padrão.
* **Detecção e Resposta:** Configurar alertas prioritários no SIEM/IDS para qualquer tráfego originado ou destinado à porta **6200/TCP**, que constitui um **Indicador de Comprometimento (IoC)** definitivo para esta exploração.

---

## 8. Apêndice – Evidências

* **Evidence 01:** `[./evidencias/meta2/nmap_full_scan.png]` – Output técnico do Nmap detalhando a vasta superfície de ataque exposta e serviços vulneráveis.
* **Evidence 02:** `[./evidencias/meta2/ftp_backdoor.png]` – Captura de tela da confirmação via script NSE da presença ativa do backdoor no serviço vsftpd.

---
