# 📂 Fase 03: Enumeration (Enumeração)

![Status: Concluído](https://img.shields.io/badge/Status-Conclu%C3%ADdo-success?style=for-the-badge)
![Nível: Sênior](https://img.shields.io/badge/N%C3%ADvel-Master-gold?style=for-the-badge)
![Conformidade: NIST & OWASP](https://img.shields.io/badge/Compliance-NIST%20%7C%20OWASP-blue?style=for-the-badge)

## 🎯 Objetivo da Fase
Nesta etapa, transformamos dados brutos em inteligência técnica acionável. O objetivo foi interagir ativamente com os serviços para identificar banners de versão, diretórios ocultos e configurações permissivas que servirão de vetores para as próximas fases.

---

## 🏗️ Estratégia de Rede & Superfície de Ataque

| Alvo | Papel no Lab | Vetor Crítico Identificado | Complexidade |
| :--- | :--- | :--- | :--- |
| **Alvo 01 (Apache)** | Foothold (Ponto de Apoio) | Injeção de Comandos (RCE) | Média |
| **Alvo 02 (Win 10)** | Lateral Movement Target | SMB Vulnerável / WinRM | Alta |
| **Alvo 03 (Meta2)** | Pivot / Data Exfiltration | Serviços Legados & Backdoors | Baixa |

---

## 📚 Frameworks e Metodologias de Referência

Para garantir um padrão de auditoria internacional, esta fase foi estruturada sob os seguintes pilares:

* **PTES (Penetration Testing Execution Standard):** Padronização do fluxo de trabalho, garantindo que a coleta de informações ativas cubra todas as camadas do modelo OSI.
* **MITRE ATT&CK® (TA0007 - Discovery):** Mapeamento das técnicas utilizadas pelos adversários para obter conhecimento sobre o sistema e a rede interna.
* **NIST SP 800-115:** Seguimos as diretrizes do *Technical Guide to Information Security Testing and Assessment* para garantir a integridade dos testes.
* **OWASP WSTG:** Aplicação do *Web Security Testing Guide* para a enumeração específica do servidor Apache e da aplicação DVWA.

---

## 🛠️ Toolstack (Arsenal Utilizado)
* **Network Discovery:** `nmap` (Service Detection & NSE Scripts).
* **Web Enumeration:** `gobuster`, `nikto`, `dirb`.
* **Windows/AD Recon:** `enum4linux-ng`, `smbclient`.
* **Banner Grabbing:** `netcat` & `curl`.

---

## 🛡️ Mentalidade Purple Team
Este repositório não foca apenas na quebra. Para cada descoberta técnica documentada, existe uma técnica de detecção e mitigação correspondente em nosso repositório de **Blue Team**.

👉 **[Ver Mitigações no Repo de Blue Team](https://github.com/seu-link-aqui)**

---
## 🛠️ Custom Tooling
Para elevar a eficiência operacional, desenvolvi ferramentas próprias para automação da fase de Enumeration:

AutoEnum (Bash): Orquestração de ferramentas legadas para varredura em massa.

BannerHunter (Python): Script de baixo nível para extração de assinaturas de serviços e análise de risco preliminar.

"A automação nesta fase visa reduzir a margem de erro humano e garantir a padronização na coleta de evidências, permitindo que o operador foque na análise lógica dos dados enquanto as ferramentas realizam o trabalho repetitivo de varredura."
---
## 📄 Relatórios Detalhados nesta Pasta
1.  [**01-Enumeration-Apache.md**](./01-Enumeration-Apache.md): Foco em Web App e exploração de RCE.
2.  [**02-Enumeration-Win10.md**](./02-Enumeration-Win10.md): Foco em protocolos de rede interna (SMB/WinRM).
3.  [**03-Enumeration-Metasploitable2.md**](./03-Enumeration-Metasploitable2.md): Foco em infraestrutura legada e backdoors.

---
