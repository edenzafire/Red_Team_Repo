# 🕶️ Dark Web Intelligence & Breach Analysis

![Phase: OSINT-DarkWeb](https://img.shields.io/badge/Phase-Dark_Web_Intelligence-black?style=for-the-badge)
![Network: Tor](https://img.shields.io/badge/Network-Tor_Onion-purple?style=for-the-badge)
![OpSec: Whonix](https://img.shields.io/badge/OpSec-Whonix_Isolated-blue?style=for-the-badge)
![Metodologia: OSINT Framework](https://img.shields.io/badge/Baseado_em-OSINT_Framework-blue?style=for-the-badge)

## 📖 Visão Geral
Esta etapa da investigação foca na coleta de inteligência em redes sobrepostas (Overlay Networks) e fóruns de cibercrime. O objetivo principal foi identificar **Data Breaches** (vazamentos de dados) que não estão indexados em motores de busca convencionais (Clear Web), buscando por credenciais expostas, documentos e pegadas digitais da persona analisada.

A investigação foi estruturada seguindo as diretrizes do **OSINT Framework** aplicadas a ambientes de Deep/Dark Web.

---

## 🛡️ Operational Security (OpSec)
Dada a natureza hostil do ambiente, a investigação foi conduzida sob um protocolo rigoroso de anonimato para prevenir a desanonimização do analista:

* **Infrastructure:** Utilização da arquitetura **Whonix** (Gateway + Workstation), garantindo que todo o tráfego seja forçado via rede Tor e prevenindo vazamentos de IP real (IP Leaks) e vazamentos de DNS.
* **Isolation:** Ambiente virtualizado e descartável, sem persistência de dados sensíveis ou contas pessoais no host principal (Ubuntu).
* **Traffic Masking:** Uso de pontes (Bridges) para ofuscação do tráfego Tor perante o ISP (Internet Service Provider).
### Para melhor verificação segue os links:

[01_opsec.md]  https://github.com/edenzafire/Portfolio_pentest/blob/main/01_Osint/02_DarkWeb/01_opsec.md
[02_torConf.md] https://github.com/edenzafire/Portfolio_pentest/blob/main/01_Osint/02_DarkWeb/02_torConf.md

## E o relatório completo você encontra no seguinte link:
[DarkWeb.md] https://github.com/edenzafire/Portfolio_pentest/blob/main/01_Osint/02_DarkWeb/DarkWeb.md

---

## 🛡️ Mapeamento MITRE ATT&CK (Reconnaissance)

A investigação simulou a perspectiva do adversário durante a fase de preparação, focando nas seguintes táticas e técnicas do framework MITRE:

| ID | Técnica | Aplicação no Projeto |
| :--- | :--- | :--- |
| **T1589.001** | **Gather Victim Identity Info: Credentials** | Busca por bancos de dados vazados contendo hashes e senhas vinculadas ao alvo. |
| **T1592.002** | **Gather Victim Host Info: Software/Config** | Identificação de tecnologias legadas citadas pelo alvo em fóruns técnicos Onion. |
| **T1593.001** | **Search Open Technical Databases** | Pivotagem de pseudônimos (nicknames) para reconstruir o histórico digital. |
| **T1597.001** | **Search Closed Sources: Threat IP** | Pesquisa em repositórios privados e "leaks" de fóruns de acesso restrito. |

---

## 🕵️ Metodologia de Coleta

### 1. Motores de Busca Onion
Utilização de indexadores especializados (ex: Torch, Ahmia, Haystak) para localizar menções a e-mails e usernames.

### 2. Repositórios de Vazamentos (Dump Sites)
Análise de fóruns de "Leaked Databases" para identificar PII (Personally Identifiable Information) como CPF, telefone e endereços em bases SQL comprometidas.

### 3. Fóruns de Discussão & Markets
Monitoramento passivo de comunidades para verificar a presença da identidade do alvo em listas de "Combos" para ataques de *Credential Stuffing*.

---

## 🧩 Principais Achados (Anonimizados)
* **Vazamento Identificado:** Presença do e-mail principal em base de dados de [SETOR MASCARADO].
* **Credenciais Expostas:** Localização de hash de senha (SHA-1) em dump histórico.
* **Pivoting Lógico:** Correlação de username secundário permitiu identificar perfis antigos em fóruns de tecnologia.

---

## 🛠️ Ferramentas Utilizadas
| Ferramenta | Função |
| :--- | :--- |
| **Whonix OS** | Sistema focado em anonimato e isolamento (Gateway/Workstation). |
| **Tor Browser** | Acesso seguro a domínios `.onion`. |
| **Hashcat** | Validação técnica e análise de complexidade de hashes encontrados. |
| **Onion Search Tools** | Automação de varredura em diretórios e wikis da Dark Web. |

---

## 📁 Evidências Técnicas
Capturas de tela do ambiente Whonix e logs de busca (com dados sensíveis tarjados) estão disponíveis em:

🔗 [**Evidence Repository - DarkWeb**](https://github.com/edenzafire/Portfolio_pentest/tree/main/01_Osint/02_DarkWeb/evidence)

---
**Nota Ética:** Este projeto tem finalidade estritamente educacional e de auditoria de exposição. Não houve interação com cibercriminosos ou transações financeiras em mercados ilícitos.

