# 🎭 Red Team Portfolio: Phase 4 - Social Engineering

> **"A segurança é um processo, não um produto. E o elo mais fraco desse processo é, quase sempre, o ser humano."**

## 📌 Visão Geral
Nesta etapa, demonstro como converter dados de **OSINT** em armas psicológicas. O foco aqui não é o software vulnerável, mas o **sistema operacional humano**. Utilizo técnicas de manipulação para testar a resiliência contra ataques de oportunidade e direcionados.

---

## 🧠 Estrutura Estratégica

### A. Gatilhos Mentais (Social Engineering Framework)
Para que um ataque de Engenharia Social funcione, ele precisa de um **Gatilho**. Neste projeto, explorei:

* **Afinidade:** Uso de temas de nicho (Lutheria e Arte) para baixar a guarda.
* **Autoridade:** Simulação de suporte técnico ou especialistas de área.
* **Urgência/Escassez:** Alertas de entregas retidas ou erros de conta.

### B. Mapeamento Tático (MITRE ATT&CK®)

| Técnica | ID | Tática | Gravidade |
| :--- | :--- | :--- | :--- |
| **Spearphishing for Info** | `T1598.002` | Reconnaissance | ![High](https://img.shields.io/badge/Risk-High-red) |
| **Spearphishing Attachment**| `T1566.001` | Initial Access | ![Critical](https://img.shields.io/badge/Risk-Critical-black) |
| **Spearphishing Link** | `T1566.002` | Initial Access | ![Medium](https://img.shields.io/badge/Risk-Medium-orange) |

---

## 🚀 Cenários de Exploração (Self-Hacking)

### 1️⃣ O "Manuscrito do Luthier" (Phishing Direcionado)
* **Vetor:** E-mail customizado.
* **O Ataque:** Envio de um PDF/ZIP com "conteúdo exclusivo" sobre técnicas de verniz.
* **Objetivo:** Execução de Macro ou captura de credenciais via formulário falso.
* **Evidência:** *[Link/Print do E-mail customizado no Drawing]*

### 2️⃣ A "Entrega Interrompida" (Smishing/Urgência)
* **Vetor:** SMS (Short Message Service).
* **O Ataque:** Mensagem alertando sobre uma falha logística em um pedido de delivery.
* **Objetivo:** Levar o alvo a uma página de login clonada para capturar dados financeiros.
* **Evidência:** *[Link/Print da página clonada com campos de dados borrados]*

---

## 🛡️ Conexão Purple Team (Mirror Project)

Este ataque serve de base para o fortalecimento do **Blue Team**. Para cada vulnerabilidade humana explorada aqui, implementei uma camada de defesa:

* **Defesa 01:** Implementação de MFA (2FA) resistente a Phishing.
* **Defesa 02:** Configuração de filtros de SPF/DKIM/DMARC para evitar spoofing.
* **Defesa 03:** Treinamento de conscientização e análise de cabeçalhos de e-mail.

👉 **[Ver Remediação no Portfólio Blue Team](link-seu-blue-team)**

---

## ⚠️ Disclaimer
Este repositório é para fins **estritamente educacionais**. Todas as simulações foram feitas contra meus próprios ativos (Self-Hacking). O uso indevido dessas técnicas contra terceiros é ilegal e antiético.
