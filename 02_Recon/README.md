# 🛰️ Fase 02: Reconhecimento Ativo & Expansão de Superfície de ataque


![Status: Em Execução](https://img.shields.io/badge/Status-Em_Execução-yellow?style=for-the-badge)
![MITRE: Reconnaissance](https://img.shields.io/badge/MITRE_ATT%26CK-TA0043-orange?style=for-the-badge)
![Security: Ofensivo](https://img.shields.io/badge/Foco-Red_Teaming-black?style=for-the-badge&logo=kali-linux)

## 📖 Visão Geral
Esta etapa representa a transição estratégica da inteligência passiva (**OSINT**) para a interação ativa com a infraestrutura alvo. O foco aqui não é o escaneamento cego, mas o **Reconhecimento Direcionado** baseado nos artefatos colhidos na fase anterior.

> **Objetivo:** Transformar e-mails, usernames e históricos de vazamentos em pontos de extremidade técnicos (IPs, subdomínios e serviços).

---

## 🌉 A Ponte de Inteligência: Do Dado ao Ativo
Para demonstrar um workflow profissional de Pentest, o Recon é alimentado pelos seguintes outputs da OSINT:

| 📥 Output OSINT | ⚙️ Processo de Recon | 📤 Objetivo Técnico |
| :--- | :--- | :--- |
| **Usernames (@r***.m**)** | GitHub/GitLab Dorking | Identificar exposição de segredos ou infraestrutura em código. |
| **Domínios de E-mail** | DNS Enumeration & Brute-force | Mapear a topologia de rede e serviços (MX, TXT, SPF). |
| **Histórico de IPs** | Infrastructure Lookup | Verificar a persistência de ativos legados e vizinhança de rede. |

---

## 🛠️ Stack Tecnológica & Técnicas
Seguindo o framework **MITRE ATT&CK**, as seguintes técnicas são aplicadas:

### 1. Pesquisa de Ativos Técnicos (T1590)
* **Ferramentas:** `Amass`, `Subfinder`, `DNSRecon`.
* **Ação:** Identificação de subdomínios e zonas de DNS que possam hospedar ambientes de teste (Staging) ou serviços esquecidos.

### 2. Varredura Ativa de Rede (T1595)
* **Ferramentas:** `Nmap`, `Masscan`.
* **Ação:** Identificação de serviços expostos e fingerprinting de sistemas operacionais, buscando portas críticas vinculadas ao histórico de vazamentos.

### 3. Busca de Repositórios e Segredos (T1593)
* **Ferramentas:** `TruffleHog`, `GitHub Dorks`.
* **Ação:** Varredura em perfis identificados para detectar chaves de API ou credenciais codificadas que possam permitir acesso inicial.

---

## 📊 Resultados Esperados
* Mapeamento completo da Superfície de Ataque Externa (EASM).
* Identificação de vetores prioritários para a fase de **03_Enumeration**.
* Relatório de ativos críticos com exposição não intencional.

---
📫 **Interessado no processo completo?** Veja a fase de [01_OSINT](../01_Osint/) ou entre em contato via [LinkedIn](SEU_LINK_AQUI).
