# 🔍 Estudo de Caso: Auto-OSINT e Pegada Digital Legada
[![Framework: MITRE ATT&CK](https://img.shields.io/badge/Framework-MITRE%20ATT%26CK-orange)](https://attack.mitre.org/)
[![Status: Finalizado](https://img.shields.io/badge/Status-Finalizado-green)](#)
[![Nível de Risco: Alto](https://img.shields.io/badge/Risco-Alto-red)](#)

## 📌 Visão Geral
Este projeto demonstra a aplicação de técnicas de **Inteligência de Fontes Abertas (OSINT)** para mapear a superfície de ataque de um indivíduo a partir de identificadores antigos (e-mails ativos desde 2011). 

O objetivo é evidenciar como dados vazados em brechas de segurança ao longo de uma década podem ser correlacionados para realizar **Doxing**, **Credential Stuffing** e rastreamento geográfico.

## 🛠️ Metodologia e Ferramentas
A investigação seguiu o framework **MITRE ATT&CK**, focando na tática de **Reconnaissance (TA0043)**.

* **Coleta de Dados:** Busca passiva em bases de dados de vazamentos (Breach Data).
* **Processamento:** Scripts em Python para limpeza e normalização de dados.
* **Visualização:** Modelagem de relacionamentos no Maltego CE.
* **Análise:** Avaliação crítica de hashes de senhas e padrões de comportamento digital.

## 🛡️ Técnicas MITRE ATT&CK Mapeadas
| ID | Técnica | Descrição |
| :--- | :--- | :--- |
| **T1589.002** | Gather Victim Identity Info | Coleta de e-mails legados para pivotagem. |
| **T1593.001** | Search Open Technical Databases | Consulta a repositórios de vazamentos e redes sociais. |
| **T1592.005** | Gather Victim Digital Network Info | Identificação de Device IDs e tokens de aplicativos. |

## 📊 Resumo de Resultados
* **Identidade:** Nome completo, data de nascimento e localização mapeados com sucesso.
* **Credenciais:** Exposição de hashes de alta e baixa complexidade (bcrypt, PBKDF2, SHA1).
* **Geolocalização:** Identificação de rotas e cidades de residência através de vazamentos de apps de delivery.

---
👉 **[CLIQUE AQUI PARA LER O RELATÓRIO TÉCNICO COMPLETO](./relatorio_detalhado.md)**
