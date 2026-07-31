# # 🎭 Red Team Portfolio: Phase 3 - Social Engineering
## Project 03: Operation Luthieria Flamenca

![Social Engineering](https://img.shields.io/badge/Focus-Human_Element-red?style=for-the-badge&logo=target)
![MITRE ATT&CK](https://img.shields.io/badge/Framework-MITRE_ATT%26CK-orange?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Validated_Exploitation-success?style=for-the-badge)

> "A segurança é um processo, não um produto. E o elo mais fraco desse processo é, quase sempre, o ser humano." — **Bruce Schneier**
---
## 📁 Navegação do Repositório
Acesse os componentes detalhados deste projeto:

*   [**`📂 src/`**](./src) - Código-fonte dos payloads, scripts de ofuscação e geradores de HTML Smuggling.
*   [**`📂 docs/`**](./docs) - Relatórios detalhados, metodologias de ataque e planejamento estratégico.
*   [**`📂 evidence/`**](./evidence) - Capturas de tela (Prints), logs de execução e provas de conceito (PoC).

---
## 📌 Visão Geral
Nesta etapa, demonstro a conversão de dados brutos de **OSINT** (Open Source Intelligence) em vetores de ataque psicológico. O foco não é o software vulnerável, mas o **Sistema Operacional Humano**. Utilizo técnicas de manipulação baseadas em perfis comportamentais para testar a resiliência contra ataques de **Spear Phishing**.

---

## 🧠 Estrutura Estratégica (The Human Exploit)

### A. Gatilhos Mentais (Psychological Triggers)
Para romper a barreira de desconfiança do alvo, explorei os seguintes gatilhos do [*Social Engineering Framework*](https://www.social-engineer.org/framework/attack-vectors/)

*   **Afinidade (Rapport):** Uso de temas de nicho (Luthieria Flamenca) para baixar a guarda através de interesses comuns identificados via OSINT.
*   **Autoridade Simulada:** Comunicação estruturada como "Especialista em Medidas Técnicas", evocando respeito técnico.
*   **Curiosidade/Escassez:** Oferta de conteúdo raro (medidas originais de Paco de Lucía) que não está disponível publicamente.

### B. Mapeamento Tático (MITRE ATT&CK®)

| Técnica | ID | Tática | Gravidade |
| :--- | :--- | :--- | :--- |
| **Spearphishing for Info** | `T1598.002` | Reconnaissance | 🟡 Média |
| **Spearphishing Attachment**| `T1566.001` | Initial Access | 🔴 Crítica |
| **Spearphishing Link** | `T1566.002` | Initial Access | 🔴 Crítica |
| **User Execution** | `T1204.002` | Execution | 🔴 Crítica |

---

## 🚀 Cenário de Exploração: "O Manuscrito do Luthier"

**Alvo:** Estação de Trabalho Windows 10 (Recém-formatada Hostname: `Win10-Lab`).
**Vetor:** Spear Phishing via HTML Smuggling e payload ofuscado.

### 🔬 O Ciclo do Ataque (Kill Chain):
1.  **Recon (OSINT):** Identificação da paixão do alvo por violões flamencos.
2.  **Weaponization:** Desenvolvimento do `veneno.cpp` e ofuscação via `encrypt.py`.
3.  **Delivery:** Levantamento de servidor simulando repositório de luthieria com o `phishing.html`.
4.  **Exploitation:** O alvo executa o arquivo devido ao alto valor percebido do conteúdo.
5.  **Control:** Estabelecimento de sessão Meterpreter para exfiltração de dados e persistência.

---

## 🛡️ Conexão Purple Team (Mirror Project)

Este ataque não é um fim em si mesmo, mas a base para o fortalecimento do **Blue Team**. Para cada manipulação humana, propus uma camada de defesa técnica:

*   **Defesa 01 (Prevenção):** Implementação de **MFA (FIDO2/WebAuthn)** resistente a interceptação.
*   **Defesa 02 (Deteção):** Configuração de políticas de **Attack Surface Reduction (ASR)** no Windows para bloquear scripts de Office/PDF.
*   **Defesa 03 (Conscientização):** Gamificação de treinamentos de análise de cabeçalhos e verificação de integridade de links.

👉 [Ver análize detalhada do ataque no portfólio low level](#)

---

👉 [Ver Remediação Detalhada no Portfólio Blue Team](https://github.com/edenzafire/Blue_Team_Repo/tree/main/03_Identity_Access_Management_IAM)

---

## ⚠️ Disclaimer
Este repositório é para fins estritamente educacionais. Todas as simulações foram realizadas em ambiente de laboratório isolado contra ativos próprios (**Self-Hacking**). O uso dessas técnicas sem autorização é ilegal e viola os princípios éticos de Segurança da Informação.
