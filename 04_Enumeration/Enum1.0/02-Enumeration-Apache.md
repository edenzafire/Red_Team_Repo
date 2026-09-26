# Relatório Técnico de Enumeração e Exploração Inicial
## Alvo 02– Apache / DVWA (Ponto de Entrada)

**Author:** Eden Zafire  / Nikolay (Lab Environment)  
**Data:** 28 de Fevereiro de 2026  
**MITRE ATT&CK:** T1595.002, T1190  
**Status:** Concluído  
**Ambiente:** Laboratório Controlado (Debian 12 / MacBook 2008)

---

# 1. Executive Summary

Este relatório detalha a fase de reconhecimento e exploração inicial do host **MAC-DEBIAN-SRV**. A análise confirmou que o servidor atua como um elo fraco na infraestrutura, permitindo a transição de um atacante externo para a rede interna.

As principais descobertas incluem:
- **Exposição de Superfície:** Diretórios sensíveis revelados via força bruta (Gobuster).
- **Falha Crítica de Injeção:** Vulnerabilidade de *Command Injection* confirmada no DVWA.
- **Vetor de Pivoting:** O host possui conectividade que permite saltar para ativos internos (Windows 10 e Metasploitable 2).

O risco é classificado como **Crítico**, servindo como o *Foothold* necessário para o comprometimento total da rede interna.

---

# 2. Escopo

**Host Alvo:**
- **Hostname:** MAC-DEBIAN-SRV
- **IP:** 192.168.x.y
- **OS:** Debian 12 (Bookworm)
- **Serviços:** Apache 2.4.x, MySQL/MariaDB
- **Aplicação:** Damn Vulnerable Web Application (DVWA)

**Objetivo:**
Mapear a superfície de ataque web e obter **RCE (Remote Code Execution)** para validar a viabilidade de movimentação lateral (Pivoting).

---

# 3. Metodologia

Seguindo o framework **MITRE ATT&CK**, a operação foi dividida em:
1.  **Reconhecimento Ativo:** Varredura de portas e serviços (Nmap).
2.  **Enumeração Web:** Descoberta de diretórios não indexados (Gobuster).
3.  **Exploração de Vulnerabilidade:** Teste de injeção de comandos e análise de vulnerabilidades (Nikto/Manual).

---

# 4. Timeline Técnica

* **00:00** – Início da varredura de infraestrutura com Nmap.
* **00:10** – Identificação de banners de versão do Apache 2.4.x.
* **00:25** – Finalização do Gobuster; identificação da estrutura de diretórios do DVWA.
* **00:40** – Execução de Scan de vulnerabilidades com Nikto.
* **00:55** – Validação manual de Command Injection e confirmação de RCE.

---

# 5. Descobertas Técnicas

## 5.1 Reconhecimento de Infraestrutura (Nmap)

### Comando Executado
`nmap -sV -sC -Pn 192.168.x.y -p 80,443 -oN ./evidencias/apache/nmap_scan.txt`

### Análise
A varredura confirmou o Apache 2.4.x em execução. A exposição de banners de versão facilita a correlação com CVEs conhecidos e o planejamento de exploits específicos.

---

## 5.2 Enumeração de Diretórios (Gobuster)

### Comando Executado
`gobuster dir -u http://192.168.x.y/dvwa/ -w /usr/share/wordlists/dirb/common.txt -x php,txt,html -o ./evidencias/apache/gobuster.txt`

### Resultado
A ferramenta mapeou a estrutura interna da aplicação, revelando scripts e endpoints que direcionaram o ataque para módulos vulneráveis como o Command Injection.

---

## 5.3 Exploração – Command Injection (RCE)

### Técnica MITRE
**T1190** – Exploit Public-Facing Application

### Payload de Validação
Inserido na funcionalidade "Ping" do DVWA:
`127.0.0.1; whoami; uname -a; ip a`

### Análise Técnica
O servidor falha em sanitizar caracteres de encadeamento de comandos (`;`). 
- **Execução:** O comando rodou com privilégios de `www-data`.
- **Impacto:** Confirmação de execução de código no nível do SO, permitindo extração de informações sensíveis do sistema.

---

# 6. Planejamento de Movimentação Lateral (Pivoting)

A exploração do comando `ip a` confirmou interfaces de rede adicionais.
- **Estratégia:** O host MAC-DEBIAN-SRV será utilizado como um **Jump Server** (Pivô).
- **Alvos Internos:** Escaneamento e ataque ao Windows 10 e Metasploitable 2 a partir deste ponto de entrada.

---

# 7. Avaliação de Risco

* **Classificação:** Crítico
* **Impacto Técnico:** Execução remota de comandos e acesso ao sistema de arquivos.
* **Impacto Organizacional:** Possibilidade de evasão de firewall perimetral e movimentação lateral para o Controlador de Domínio.

---

# 8. Recomendações de Mitigação

### 8.1 Aplicação
- Implementar sanitização rigorosa (Ex: `escapeshellarg()` no PHP).
- Utilizar listas brancas (allowlists) para entradas de usuários.

### 8.2 Infraestrutura
- Desativar `ServerTokens` e `ServerSignature` no Apache.
- Implementar Segmentação de Rede (VLANs/DMZ) para isolar o servidor web da rede interna de usuários e AD.

---

# 9. Apêndice – Evidências

* **Evidence 01:** [./evidencias/apache/recon_subs.png] - Scan de Versões.
* **Evidence 02:** [./evidencias/apache/rce_poc.png] - Prova de Conceito RCE.
* **Relatório Nikto:** `./evidencias/apache/nikto_report.txt`

---
