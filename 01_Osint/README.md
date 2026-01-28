# 🔍 OSINT Intelligence Gathering & Risk Assessment

![Metodologia: OSINT Framework](https://img.shields.io/badge/Baseado_em-OSINT_Framework-blue?style=for-the-badge)
![Fase: Reconnaissance](https://img.shields.io/badge/Fase-Intelligence_Gathering-orange?style=for-the-badge)
![Compliance: GDPR/LGPD](https://img.shields.io/badge/Data_Privacy-Compliance-green?style=for-the-badge)

## 📖 Visão Geral
Este diretório centraliza a fase de **Intelligence Gathering (OSINT)** do projeto, utilizando a taxonomia do **OSINT Framework** para mapear a superfície de ataque. A investigação foi estruturada para simular um cenário real de coleta de informações, focando em segurança pessoal e gestão de exposição online.

> **🛡️ Nota de Privacidade:** Todos os dados originais foram anonimizados através de técnicas de mascaramento, preservando a integridade metodológica sem expor informações sensíveis (PII).

---

## 📌 Objetivos
- **Mapear presença digital:** Identificar a pegada da persona em múltiplas camadas da web.
- **Identificar credenciais vazadas:** Localizar exposições em bases de dados históricas.
- **Avaliar exposição social:** Medir o risco de engenharia social via redes sociais.
- **Documentar boas práticas:** Estabelecer um plano de mitigação e higiene digital.

---

## 🧩 Principais Achados (Resumo Executivo)
- **Identidade:** Alto grau de correlação entre perfis, e-mail e dados biográficos.
- **Credenciais:** Senhas reutilizadas e hashes expostos em mais de 10 fontes distintas.
- **Técnico:** Vazamentos contendo endereços IP, geolocalização precisa e IDs de dispositivo Android.
- **Social:** Perfis de redes sociais vinculados à identidade civil e histórico educacional.

---

## 🚨 Avaliação de Risco

| Categoria | Nível | Impacto Potencial |
| :--- | :---: | :--- |
| **Identidade** | 🔴 Alto | Fraude de identidade e engenharia social. |
| **Credenciais** | 🔴 Alto | Ataques de *Credential Stuffing* e invasão de contas. |
| **Localização** | 🔴 Alto | Rastreamento físico e exposição de infraestrutura doméstica. |
| **Dispositivo** | 🔴 Alto | Exploração de tokens de sessão e identificadores móveis. |
| **Comportamento**| 🟡 Médio | Mapeamento de rotinas e padrões de consumo. |

---

## 🔐 Plano de Mitigação
- Alterar todas as credenciais expostas para senhas únicas e complexas.
- Implementação obrigatória de **MFA (Multi-Factor Authentication)**.
- Desativação de contas inativas identificadas durante a varredura.
- Criação de e-mails compartimentados para novos cadastros (Alias).

---

## 📁 Estrutura do Diretório

OSINT/
│
├── README.md               # Este guia principal
├── 01_ClearWeb             # Relatório de inteligência em fontes abertas
│   └── Link: [https://github.com/edenzafire/Portfolio_pentest/tree/main/01_Osint/01_ClearWeb](https://github.com/edenzafire/Portfolio_pentest/tree/main/01_Osint/01_ClearWeb)
├── 02_DarkWeb              # Investigação de vazamentos e bases de dados
│   └── Link: [https://github.com/edenzafire/Portfolio_pentest/tree/main/01_Osint/02_DarkWeb](https://github.com/edenzafire/Portfolio_pentest/tree/main/01_Osint/02_DarkWeb)
└── ferramentas.mb          # Metodologia de ferramentas, prints e anotações técnicas
