# Relatório de Enumeração: Alvo 02 (Windows 10 Pro - Interno)

![Status: Em Andamento](https://img.shields.io/badge/Status-Em%20Andamento-yellow?style=for-the-badge)
![Nível: Intermediário](https://img.shields.io/badge/N%C3%ADvel-Intermedi%C3%A1rio-blue?style=for-the-badge)
![MITRE: T1046](https://img.shields.io/badge/MITRE%20ATT%26CK-T1046-red?style=for-the-badge)

## 1. Informações do Alvo
* **Hostname:** `WIN10-CLIENT-01`
* **Endereço IP:** `192.168.x.z` (Rede Interna)
* **Sistema Operacional:** Windows 10 Pro
* **Contexto:** Estação de trabalho identificada como alvo crítico para movimentação lateral.

---

## 2. Vetores de Enumeração Identificados

Nesta fase, focamos em protocolos de comunicação que permitem a descoberta de serviços ativos e possíveis falhas de configuração em ambiente Windows.

### Ataque 01: Enumeração de SMB (Server Message Block)
**Descrição:** Identificação de compartilhamentos de rede e sessões nulas que podem expor arquivos sensíveis ou nomes de usuários.

* **Técnica MITRE ATT&CK:** [T1021.002 - Remote Services: SMB/Windows Admin Shares](https://attack.mitre.org/techniques/T1021/002/)
* **Ferramentas:** `nmap`, `enum4linux-ng`

#### Comandos Executados:
**Scan de Scripts SMB:**
`nmap -p 139,445 --script smb-os-discovery,smb-enum-shares 192.168.x.z`

**Enumeração Detalhada:**
`enum4linux-ng -A 192.168.x.z`

#### Evidências:
> [!IMPORTANT]
> Insira o print mostrando se o "Guest Access" está habilitado ou se há compartilhamentos como `C$` ou `ADMIN$` visíveis.
> ![SMB Enumeration](./evidencias/win10/smb_scan.png)

---

### Ataque 02: Enumeração de WinRM (Gerenciamento Remoto)
**Descrição:** Verificação da presença do serviço WinRM, que se estiver habilitado e mal configurado, permite execução remota de scripts (PowerShell).

* **Técnica MITRE ATT&CK:** [T1021.006 - Remote Services: Windows Remote Management](https://attack.mitre.org/techniques/T1021/006/)
* **Ferramentas:** `nmap`

#### Comandos Executados:
**Identificação de Porta WinRM:**
`nmap -p 5985,5986 -sV 192.168.x.z`

#### Evidências:
> [!IMPORTANT]
> Capture o banner do serviço WinRM. Se ele responder, é um forte candidato para ataques de força bruta ou uso de credenciais capturadas.
> ![WinRM Discovery](./evidencias/win10/winrm_port.png)

---

## 3. Análise de Risco 
> [!CAUTION]
> **Impacto no Negócio:** A exposição do protocolo SMB em versões antigas ou com permissões frouxas pode levar ao vazamento de dados corporativos e facilitar a propagação de Ransomware (como o WannaCry). O WinRM aberto aumenta a superfície de ataque para movimentos laterais.

---

## 4. 🛡️ Defesa e Remediação (Blue Team)
As estratégias de endurecimento (Hardening) para Windows 10, como desativar SMBv1 e restringir o WinRM via GPO, estão documentadas aqui:

👉 [Acessar Repositório Blue Team - Hardening Windows](./link-para-seu-outro-repo)

---
