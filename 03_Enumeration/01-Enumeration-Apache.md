
# Relatório de Enumeração: Alvo 01 (Ponto de Entrada - Apache/DVWA)

![Status: Concluído](https://img.shields.io/badge/Status-Conclu%C3%ADdo-success?style=for-the-badge)
![Nível: Intermediário](https://img.shields.io/badge/N%C3%ADvel-Intermedi%C3%A1rio-blue?style=for-the-badge)
![MITRE: T1595](https://img.shields.io/badge/MITRE%20ATT%26CK-T1595-red?style=for-the-badge)

## 1. 🛡️ Defesa e Remediação (Blue Team)
As contrapartidas técnicas, regras de Firewall e patches de correção para este cenário estão detalhados em nosso repositório de **Blue Team**:

👉 [Acessar Repositório Blue Team - Mitigação Apache](./link-para-seu-outro-repo)

---
## 1. Informações do Alvo
* **Hostname:** `MAC-DEBIAN-SRV` (MacBook Pro - Lab)
* **Endereço IP:** `192.168.x.y` 
* **Sistema Operacional:** Debian 12 (Bookworm)
* **Serviços Principais:** Apache HTTP Server 2.4.x, MySQL/MariaDB.
* **Aplicação:** Damn Vulnerable Web Application (DVWA).

---

## 2. Foco de Enumeração e Ataques

Nesta fase, o objetivo estratégico é mapear a superfície de ataque da aplicação web para encontrar um vetor de **RCE (Remote Code Execution)**. Este acesso inicial no MacBook servirá como "Pivot" para alcançar a rede interna onde residem o Windows 10 e o Metasploitable 2.

### Ataque 01: Reconhecimento de Infraestrutura e Diretórios
**Descrição:** Identificação de banners de versão e busca por diretórios ocultos ou sensíveis no servidor Apache que possam conter arquivos de configuração ou painéis administrativos não indexados.

* **Técnica MITRE ATT&CK:** [T1595.002 - Active Scanning: Vulnerability Scanning](https://attack.mitre.org/techniques/T1595/002/)
* **Ferramentas:** `nmap`, `gobuster`

#### Comandos Executados (Debian Atacante):

**Varredura de Serviços (Nmap):**
`nmap -sV -sC -Pn 192.168.x.y -p 80,443 -oN ./evidencias/apache/nmap_scan.txt`

**Busca de Diretórios (Gobuster):**
`gobuster dir -u http://192.168.x.y/dvwa/ -w /usr/share/wordlists/dirb/common.txt -x php,txt,html -o ./evidencias/apache/gobuster.txt`

#### Evidências:
> [!IMPORTANT]
> Insira os screenshots comprovando as versões encontradas e os diretórios descobertos através do Nmap e Gobuster.
> ![Reconhecimento](./evidencias/apache/recon_subs.png)

---

### Ataque 02: Análise de Vulnerabilidades Web (Injeção de Comandos)
**Descrição:** Exploração de falhas de sanitização em formulários web. O foco é a vulnerabilidade de **Command Injection**, essencial para obter execução de código no nível do sistema operacional (Shell).

* **Técnica MITRE ATT&CK:** [T1190 - Exploit Public-Facing Application](https://attack.mitre.org/techniques/T1190/)
* **Ferramentas:** `nikto`, `Manual Testing (Browser)`

#### Comandos e Testes Sugeridos:

**Scan de Vulnerabilidades (Nikto):**
`nikto -h http://192.168.x.y/dvwa/ -o ./evidencias/apache/nikto_report.txt`

**Teste Manual de RCE (Payload):**
Inserir no campo de input da funcionalidade "Command Injection" do DVWA:
`127.0.0.1; whoami; uname -a; ip a`

#### Evidências:
> [!IMPORTANT]
> Capture a tela do DVWA exibindo o resultado do comando `whoami` ou `ip a` injetado com sucesso.
> ![Prova de Conceito RCE](./evidencias/apache/rce_poc.png)

---

## 3. Planejamento de Movimentação Lateral (Pivoting)

A enumeração confirmou que o Apache está vulnerável a injeção de comandos. O próximo passo técnico será a estabilização de uma **Reverse Shell** para realizar a enumeração detalhada de interfaces de rede interna (`ip a` ou `ifconfig`).

Isso permitirá que o atacante utilize este MacBook como um **Jump Server** (Pivô) para escanear e atacar os alvos protegidos na rede interna:


---

## 4. Análise de Risco

> [!CAUTION]
> **Impacto no Negócio:** O comprometimento deste servidor Apache representa um risco **Crítico**. Por estar mal segmentado, >

---

## 5. Recomendações de Mitigação (Preview)
Para sanar as falhas encontradas nesta fase de enumeração, as seguintes medidas são necessárias:
* **Desativação de Banners:** Impedir que o Apache exiba sua versão exata.
* **Sanitização de Inputs:** Corrigir o código da aplicação para impedir Command Injection.
* **Segmentação de Rede:** Isolar o servidor web em uma DMZ para impedir o Pivoting.

## 6. 🛡️ Defesa e Remediação (Blue Team)
As contrapartidas técnicas, regras de Firewall e patches de correção para este cenário estão detalhados em nosso repositório 

---
