# 🕵️ Relatório OSINT: Enumeração de Pegada Digital
**Frameworks:** PTES (Fase 1) | NIST SP 800-115 | MITRE ATT&CK (Reconnaissance)
**Analista:** Zafire Daniel | **Data:** 2026  
**Alvo:** `e******d***@***.com` (Sanitizado)  
**Escopo:** Mapeamento de contas ativas e análise de superfície de exposição inicial.

---

## 📑 1. Enquadramento Metodológico (Compliance)

Nesta fase de coleta passiva e semi-passiva, aplicamos:

* **PTES (Intelligence Gathering):** Coleta de nível 1 focada em identificadores de e-mail.
* **MITRE ATT&CK (T1589.002):** Gather Victim Identity Information (Email Addresses).
* **NIST SP 800-115:** Execução de **Target Identification** e **Network Discovery** no nível de aplicação (SaaS).

---

## 🗺️ Fluxo de Dados e Pivoting (Mermaid)

```mermaid
graph TD
    %% Define o início
    A[fa:fa-envelope Target Email] --> B{fa:fa-cogs Reconhecimento}

    %% Ferramentas
    B --> C[fa:fa-search Holehe]
    B --> D[fa:fa-share-alt SocialScan]
    B --> E[fa:fa-database h8mail]

    %% Resultados
    C --> F(Amazon/Office365)
    D --> G(Instagram/X)
    E --> H[fa:fa-shield Status: Clean]

    %% Próximos Passos
    F & G --> I[Identificação de Usernames]
    I --> J((fa:fa-arrow-right Fase 02: Maigret))

    %% Estilização
    style A fill:#f9f,stroke:#333,stroke-width:2px
    style H fill:#9f9,stroke:#333
    style J fill:#3498db,stroke:#fff,stroke-width:2px,color:#fff
```
## 🛠️ 2. Ferramentas Utilizadas & Metodologia NIST

| Ferramenta | Badge | Função Técnica | Objetivo NIST (SP 800-115) |
| :--- | :--- | :--- | :--- |
| **Holehe** | ![Holehe](https://img.shields.io/badge/Holehe-API_Check-blue?style=flat-square) | Verificação de registro via recovery | **Target ID** (SaaS Footprint) |
| **SocialScan** | ![SocialScan](https://img.shields.io/badge/SocialScan-Presence-green?style=flat-square) | Validação de e-mail e username | **Discovery Scanning** |
| **h8mail** | ![h8mail](https://img.shields.io/badge/h8mail-Breach_Analysis-red?style=flat-square) | Busca em repositórios de vazamento | **Vulnerability Review** |

---

## ⚠️ 3. Análise de Riscos (Mapeamento MITRE ATT&CK)

Com base na enumeração realizada, foram mapeadas as seguintes superfícies de ataque:

1. **Exposição de E-Commerce (Amazon):** Técnica **T1591**. Facilita a execução de engenharia social baseada em falsas notificações de entrega ou faturamento.
2. **Uso de Office365:** Técnica **T1589**. Confirma a inserção do alvo em ecossistema corporativo/estudantil, elevando o risco de *Spear-Phishing*.
3. **Hobbyist/Dev Exposure (CodePen/Replit):** Técnica **T1593**. Identifica compartilhamento de código público, onde metadados ou segredos (API Keys) podem estar expostos.

---

## 🕵️‍♂️ 3.1 Análise de Atribuição e Correlação (Breach Enrichment)

> [!IMPORTANT] A Descoberta do "Fio da Meada"
> A análise de 10 fontes de vazamentos (2018-2023) permitiu a transição da investigação de um **E-mail anônimo** para uma **Identidade Real confirmada**.

### 🔗 Cadeia de Pivoting Encontrada:
1. **Ponto de Partida:** E-mail `e******d***@***.com`.
2. **Descoberta de Identidade (James/Habib's):** Vazamentos de delivery revelaram o nome real e coordenadas geográficas em **C******-PR**.
3. `e***d********` | **Dubsmash / Lazer** | **Handle Padrão:** Identificado como o identificador primário para serviços de entretenimento e gaming. |
4. `e******_g***` | **Twitter / X** | **Identidade Pública:** Utilizado para projeção em redes sociais abertas; alto potencial de coleta de opiniões e interações. |
5. `e******gd**` | **Edmodo / Educação** | **Pivô Acadêmico:** Vinculação direta com o ambiente estudantil e histórico de aprendizado técnico. |
6. `e****.d********_` | **Instagram** | **Vetor Social:** Perfil com maior densidade de metadados, fotos de terceiros e conexões familiares (Social Graph). |
7. `e***g*********` | **James Delivery** | **GEOINT:** Vinculação crítica com dados de consumo físico, permitindo a localização geográfica precisa. |

---
---
###📊 2. O Diagrama de "Rastro de Migração" (Mermaid)

```mermaid
graph TD
    %% Fontes de Vazamento
    subgraph "Fontes de Dados (Histórico)"
    L1[fa:fa-pizza-slice James/Habib's] -- "Localização: PR" --> ID
    L2[fa:fa-twitter Twitter/Deezer] -- "Username: z***.m*" --> ID
    L3[fa:fa-graduation-cap Edmodo] -- "Perfil Estudantil" --> ID
    end

    %% Identidade Central
    ID(fa:fa-user-check Identidade Consolidada)

    %% Redes Atuais
    subgraph "Presença Digital Ativa (Fase 02/03)"
    ID --> FB[fa:fa-facebook Facebook: Ativo desde 2011]
    ID --> IG[fa:fa-instagram Instagram: 2 Perfis]
    ID --> X[fa:fa-twitter X: Criado Ago/2024]
    end

    %% Estilos
    style ID fill:#f1c40f,stroke:#333,stroke-width:4px
    style L1 fill:#ffcccc
    style FB fill:#3498db,color:#fff
```
---

## 📂 4. Acesso Rápido aos Artefatos (Cadeia de Custódia)

### 🛡️ Verificação de Integridade
| Arquivo | Descrição | SHA-256 Hash |
| :--- | :--- | :--- |
| `resultado_holehe.txt` | Log Bruto Holehe | `02c325508e1d6e8022ebb719a802b58d113005816ea63d1489df0f692add6965` |
| `resultado_socialscan.txt`| SocialScan | `fc90563d9a777444d09c37612014399e6d6bb2e3a376549bc65e45bbb559edf7 `|
| `resultado_h8mail.txt` | Log de Vazamentos | `4239d434b32133090e9bfd5d5845fe5e6efdf061c67ae0515cfe5f19752e8304` |
| `SESSAO_COMPLETA.log`| Sessão completa | `566f8d9593df6ac8fae2a0517d5c4dba5b5997f074b906ce15ceca9a6d6866d2 `| 

### 📄 Logs e Evidências
* 📜 [Log de Presença (Holehe)](https://github.com/edenzafire/Red_Team_Repo/blob/main/01_Osint/01_ClearWeb/evidences/Email/resultado_holehe_filtrado.txt)
* 📜 [Log de Vazamentos (h8mail)](https://github.com/edenzafire/Red_Team_Repo/blob/main/01_Osint/01_ClearWeb/evidences/Email/resultado_h8mail.txt)
* 📜 [Log de Vazamentos (SocialScan)](https://github.com/edenzafire/Red_Team_Repo/blob/main/01_Osint/01_ClearWeb/evidences/Email/resultado_socialscan.txt)
* 📜 [Log de gravação do Terminal ](https://github.com/edenzafire/Red_Team_Repo/blob/main/01_Osint/01_ClearWeb/evidences/Email/SESSAO_COMPLETA.log)
* 🖼️ [Captura de Tela - Resultados](https://github.com/edenzafire/Red_Team_Repo/tree/main/01_Osint/01_ClearWeb/evidences/Email/screenshots)

---

> [!TIP] Conclusão da Fase 01
> A enumeração de e-mail foi concluída com sucesso, permitindo o **Pivoting** para o Username Principal que será o objeto de estudo detalhado na **Fase 02 (Análise de Username)**.
