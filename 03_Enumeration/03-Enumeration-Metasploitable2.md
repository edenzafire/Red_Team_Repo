# Relatório de Enumeração: Alvo 03 (Metasploitable 2 - Linux)

![Status: Concluído](https://img.shields.io/badge/Status-Conclu%C3%ADdo-success?style=for-the-badge)
![Nível: Iniciante](https://img.shields.io/badge/N%C3%ADvel-Iniciante-green?style=for-the-badge)
![MITRE: T1046](https://img.shields.io/badge/MITRE%20ATT%26CK-T1046-red?style=for-the-badge)

## 1. Informações do Alvo
* **Hostname:** `METASPLOITABLE-02`
* **Endereço IP:** `192.168.x.w`
* **Sistema Operacional:** Linux (Ubuntu 8.04 - Vulnerável por design)
* **Contexto:** Servidor de serviços legados identificado na rede interna durante o pivoting.

---

## 2. Vetores de Enumeração Identificados

O Metasploitable 2 expõe uma vasta gama de serviços. O foco aqui foi identificar vetores de entrada rápida (Backdoors) e serviços de rede mal configurados.

### Ataque 01: Varredura de Serviços e Versões
**Descrição:** Levantamento exaustivo de todas as portas abertas para identificar serviços obsoletos com vulnerabilidades conhecidas (CVEs).

* **Técnica MITRE ATT&CK:** [T1595.002 - Active Scanning: Vulnerability Scanning](https://attack.mitre.org/techniques/T1595/002/)
* **Ferramentas:** `nmap`

#### Comandos Executados:
**Scan Completo (Todas as portas):**
`nmap -sV -p- -T4 192.168.x.w -oN ./evidencias/meta2/nmap_full.txt`

#### Evidências:
> [!IMPORTANT]
> O Metasploitable mostrará portas como 21 (FTP), 23 (Telnet) e 1524 (Ingreslock). Tire um print do output do Nmap destacando a porta 21 (vsftpd 2.3.4).
> ![Nmap Full Scan](./evidencias/meta2/nmap_full_scan.png)

---

### Ataque 02: Enumeração de FTP e Backdoors Conhecidos
**Descrição:** Verificação do serviço FTP para confirmar se a versão instalada possui o famoso backdoor que permite acesso root imediato.

* **Técnica MITRE ATT&CK:** [T1210 - Exploitation of Remote Services](https://attack.mitre.org/techniques/T1210/)
* **Ferramentas:** `nmap (scripts)`, `ftp`

#### Comandos Executados:
**Scripts específicos para FTP:**
`nmap -sV --script ftp-anon,ftp-vsftpd-backdoor -p 21 192.168.x.w`

#### Evidências:
> [!IMPORTANT]
> Capture o resultado do script do Nmap confirmando que o serviço é vulnerável ao backdoor do vsftpd.
> ![FTP Backdoor Check](./evidencias/meta2/ftp_backdoor.png)

---

## 3. Análise de Risco
> [!CAUTION]
> **Impacto no Negócio:** A presença do Metasploitable 2 em um ambiente produtivo é um risco **Catastrófico**. Ele contém múltiplas vulnerabilidades que permitem a tomada total do controle (Root) em segundos, servindo como base perfeita para exfiltração de dados e destruição de evidências de logs.

---

## 4. 🛡️ Defesa e Remediação (Blue Team)
Devido à natureza "propositalmente vulnerável" desta máquina, a recomendação de defesa não é apenas o patch, mas a substituição total do sistema por versões modernas e seguras.

👉 [Acessar Repositório Blue Team - Mitigação de Serviços Legados](./link-para-seu-outro-repo)

---
