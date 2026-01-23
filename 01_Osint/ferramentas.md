# 🕵️ Toolset & Methodology – OSINT Framework Alignment

![Framework: OSINT](https://img.shields.io/badge/Framework-OSINT_Framework-blue?style=for-the-badge)
![Scope: Intelligence_Gathering](https://img.shields.io/badge/Scope-Recon-orange?style=for-the-badge)

Este documento detalha o arsenal tecnológico utilizado na investigação, categorizado conforme a taxonomia do **OSINT Framework**. A estrutura abaixo reflete o fluxo lógico da coleta à análise de inteligência.

---

## 1. 📧 Email Address (Digital Identity)
Fase focada em validar a existência de contas e mapear a superfície de exposição vinculada a endereços de correio eletrônico.

* **Holehe:** Verificação de registros via API em centenas de sites (MFA/Account Discovery).
* **HaveIBeenPwned:** Consulta de histórico de incidentes de segurança e violações de dados.
* **E-mail Header Analysis:** Análise de metadados em mensagens recebidas para identificação de servidores de origem e saltos de rede.

## 2. 👤 Username (Persona Mapping)
Utilização de identificadores únicos para correlacionar perfis entre diferentes ecossistemas digitais.

* **Sherlock:** Busca automatizada de *handles* em centenas de redes sociais e fóruns.
* **WhatsMyName:** Motor de busca complementar para detecção de perfis ativos.
* **Instant Username Check:** Validação de disponibilidade de aliases para predição de contas futuras.

## 3. 🔎 Search Engines (Dorking & Discovery)
Exploração avançada de índices públicos para localização de dados sensíveis não estruturados.

* **Google Dorks:** Operadores avançados para filtragem de documentos (`filetype:pdf`), diretórios (`intitle:index.of`) e menções específicas.
* **Bing/DuckDuckGo:** Motores complementares para neutralizar bolhas de busca e filtros de remoção do Google.

## 4. 📂 Data Breaches & Leaks (Deep/Dark Web)
Acesso a repositórios de informações comprometidas para extração de PII (Personally Identifiable Information).

* **DeHashed / Snusbase:** Motores de busca em bancos de dados vazados para validação de credenciais e endereços físicos.
* **HStrike:** Consulta massiva de infraestrutura e correlação de leaks SQL.
* **SQL Dumps Analysis:** Manipulação direta de bancos de dados vazados (CSV/JSON) para extração de hashes de senha, CPFs e tokens.

## 5. 📱 Social Media (Digital Footprinting)
Análise comportamental e extração de metadados em redes sociais populares.

* **Instagram OSINT API:** Coleta de grafos de seguidores e extração de metadados de mídia.
* **ExifTool:** Análise forense de imagens para extração de coordenadas GPS, modelos de câmera e timestamps de criação.

## 6. 🛠️ Automation & Analysis (Custom Scripts)
Engenharia aplicada para normalização e processamento de grandes volumes de dados.

* **Python Scripts:** Desenvolvimento de scripts customizados para limpeza de dados (Data Wrangling) localizados no diretório [/scripts_osint](./scripts_osint).
* **Linux CLI (grep, awk, sed, jq):** Processamento rápido de grandes datasets SQL e arquivos JSON via terminal.
* **Planilhamento Técnico:** Tabulação de resultados para análise de tendências e geração de relatórios de risco.

---

## 📈 Metodologia Operacional
A investigação seguiu o ciclo de inteligência estruturado:
1.  **Planejamento:** Definição dos identificadores iniciais (Seed Data).
2.  **Coleta:** Varredura sistemática via ferramentas automatizadas e manuais.
3.  **Processamento:** Normalização de dados brutos e cruzamento de fontes (Pivoting).
4.  **Análise:** Avaliação crítica dos achados e atribuição de nível de risco.
5.  **Produção:** Compilação de evidências e relatório final.

---

## 📂 Evidências e Artefatos
Os logs de execução, capturas de tela e evidências técnicas detalhadas podem ser acessados em:
🔗 [**Evidence Repository - ClearWeb**](https://github.com/edenzafire/Portfolio_pentest/tree/main/01_Osint/01_ClearWeb/evidence)

---
**Nota Ética:** Nenhuma técnica de intrusão ativa foi realizada. Este projeto limita-se estritamente ao uso de fontes abertas e dados disponíveis publicamente em diretórios de terceiros.
