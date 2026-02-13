# 🌐 RECON_NETWORK.md - Reconhecimento de Infraestrutura Externa

![Status](https://img.shields.io/badge/Fase-02-blue?style=for-the-badge&logo=target)
![Mode](https://img.shields.io/badge/Type-Passive_Recon-green?style=for-the-badge)
![Security](https://img.shields.io/badge/OpSec-High-success?style=for-the-badge)

## 📖 Visão Geral

Esta etapa foca no **Footprinting de Rede Passivo**. O objetivo é mapear a presença da infraestrutura do alvo na internet sem disparar alertas de segurança (IDS/IPS). 

> [!IMPORTANT]
> Diferente da Fase 02 (Física), aqui analisamos a **"casca" digital**: blocos de IP, ASN, certificados e serviços indexados por motores de busca de terceiros.

---

## 🛰️ 1. Inteligência de ASN e Roteamento
### `Backbone Analysis`

A análise partiu da identificação do provedor de serviços (**ISP**) para entender a topologia de borda.

* **ASN Identificado:** 8167 (V Tal / Brasil Telecom).
* **Técnica:** ASN Lookup & BGP Routing Analysis.
* **Ferramentas:** BGPView, Whois, IPInfo.io.

> [!CAUTION]
> **Insight de Red Team:** O ASN 8167 é um backbone de grande escala. A análise de vizinhança de rede foi realizada para identificar se o alvo utiliza um IP estático ou um pool dinâmico residencial, o que dita a persistência dos payloads de C2 (Command & Control).

---

## 📡 2. Surface Mapping
### `Busca Passiva via Shodan/Censys`

Utilizando motores de busca que já possuem o "snapshot" da rede, mapeamos o que está exposto sem enviar um único pacote ao alvo.

#### **A. Impressão Digital de Serviços (Fingerprinting)**

| Filtro Shodan | Objetivo |
| :--- | :--- |
| asn:8167 | Filtrar por provedor específico |
| net:[Seu_Bloco_IP] | Isolar infraestrutura do alvo |

* **Identificação:** Mapeamento de portas comuns (80, 443, 22, 3389) indexadas no último scan.
* **Tecnologias:** Identificação de banners de servidores **Nginx** e **Apache**, permitindo prever a stack do laboratório sem interação direta.

#### **B. Certificados e Identidade (Censys/CRT.sh)**

* **Técnica:** Certificate Transparency (CT) Logs.
* **Ferramentas:** Censys Search, CRT.sh.
* **Descoberta:** Através da query `services.tls.certificates.leaf_data.subject.organization:*`, localizamos certificados SSL/TLS para subdomínios legados, expondo hostnames que não constam em registros DNS atuais.

---

## 🛠️ 3. Google Dorking de Infraestrutura

Aplicação de operadores avançados para localizar documentos de configuração ou painéis de gerenciamento indexados.

**Busca por Painéis de Gerenciamento:**
`ip:[Seu_IP] site:login | site:admin`

**Busca por Arquivos Sensíveis:**
`site:[Seu_Dominio] filetype:log | filetype:conf`

> [!TIP]
> **Resultado:** Localização de diretórios indexados que podem revelar versões de software antes mesmo da fase de Enumeração.

---

## 🧰 Ferramentas Utilizadas (100% Passivo)

| Ferramenta | Categoria | Descrição |
| :--- | :--- | :--- |
| **Shodan** | OSINT / IoT | Consulta de serviços e dispositivos expostos. |
| **Censys** | Infra Search | Análise de certificados e histórico de hosts. |
| **BGPView** | Network Intel | Mapeamento de peers e roteamento de rede. |
| **Google Dorks** | Search Intel | Mineração de dados sensíveis indexados. |

---

## 🧠 Conclusão da Inteligência de Rede

O reconhecimento de rede confirmou que o alvo opera sob uma infraestrutura de **IP dinâmico**, porém com **vazamento de metadados** em certificados TLS antigos. Isso permite correlacionar o IP efêmero a uma identidade fixa através de registros históricos.

**🚀 Próximo Passo:** [Fase 03 - Enumeração Ativa](./ENUMERATION.md)

---
> [!NOTE]
> Todas as consultas foram realizadas de forma anônima e passiva, respeitando a integridade do ambiente do alvo.
