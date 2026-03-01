# 🌐 RECON_NETWORK.md - Reconhecimento de Infraestrutura Externa

![Status](https://img.shields.io/badge/Fase-02-blue?style=for-the-badge&logo=target)
![Mode](https://img.shields.io/badge/Type-Passive_Recon-green?style=for-the-badge)
![Security](https://img.shields.io/badge/OpSec-High-success?style=for-the-badge)

---

## 📖 Visão Geral

Esta etapa foca no **Footprinting de Rede Passivo**. O objetivo é mapear a presença da infraestrutura do alvo na internet sem disparar alertas de segurança (IDS/IPS), utilizando fontes de dados de terceiros para reconstruir a topologia externa e identificar a natureza da conectividade.

> [!IMPORTANT]
> Enquanto a Fase Física foca no local e sinais de RF, aqui analisamos a **"casca" digital**: blocos de IP, ASN, registros históricos e serviços indexados.

---

## 🛰️ 1. Inteligência de ASN e Roteamento
### `Backbone Analysis & BGP View`

A análise utilizou a ferramenta **BGPView** para identificar o bloco de endereçamento e o ASN (Autonomous System Number) de origem, validando a infraestrutura de borda do alvo.

* **ASN Identificado:** `8167` (V Tal Telecom / Brasil Telecom).
* **Ponto de Presença:** `187.6.181.16`
* **Filtragem de Tráfego:** Através da análise de vizinhança de rede, identificou-se que o alvo **não utiliza** camadas de proteção em nuvem (Cloud Scrapers) como Cloudflare ou Akamai.
* **Vetor de Borda:** A infraestrutura de borda é direta no ISP, o que indica que os serviços expostos estão protegidos apenas pelo hardware local (Roteador/Firewall do Lab).

> [!CAUTION]
> **Análise de Persistência:** A verificação dos registros de Whois e do histórico de anúncios do prefixo sugeriu que o IP possui comportamento **estático/corporativo**. Diferente de IPs residenciais comuns, este cenário favorece o planejamento de longo prazo para persistência e Command & Control (C2).

---

## 🏗️ 2. Topologia de Cascateamento e Surface Mapping

Com base nos dados coletados, foi possível deduzir a topologia lógica externa. O laboratório opera em uma sub-rede isolada via **cascateamento de roteadores**.

* **Gateway 01 (ISP):** Terminação de fibra e primeira camada de NAT.
* **Gateway 02 (Lab):** Roteador secundário onde residem os ativos alvos.
* **Lógica de Acesso:** A presença de serviços indexados em motores de busca confirma a existência de regras de **Port Forwarding** configuradas no Gateway principal.



### **A. Impressão Digital Passiva (Third-Party Snapshots)**

| Ferramenta | Objetivo | Resultado/Snapshot |
| :--- | :--- | :--- |
| **Shodan** | Filtro `net:187.6.181.16` | Indexação histórica de banners (Nginx/Apache) |
| **Censys** | TLS/SSL Analysis | Certificados SSL que vinculam o IP ao domínio do Lab |
| **ViewDNS** | DNS History | Mapeamento de IPs anteriores e estabilidade do host |

---

## 🛠️ 3. Google Dorking de Infraestrutura

Utilização de operadores avançados de busca para localizar informações sensíveis que já foram indexadas, evitando interação direta com o servidor.

* **Foco em Painéis:** `ip:187.6.181.16 site:login | site:admin`
* **Foco em Configurações:** `site:[Seu_Dominio] filetype:conf | filetype:bak`

> [!TIP]
> **Insight OPSEC:** Esta técnica permite identificar a *stack* tecnológica (ex: caminhos de diretórios `/admin`, `/phpmyadmin`) sem gerar logs de acesso nos ativos do alvo.

---

## 📋 4. Matriz de Vetores Identificados (Hipóteses)

Com base no Reconhecimento Passivo, os seguintes vetores foram selecionados para validação futura:

| Vetor | Base de Evidência | Nível de Exposição |
| :--- | :--- | :--- |
| **Acesso Remoto** | Porta 22/3389 indexada no Shodan | Direto (Port Forward) |
| **Serviços Web** | Certificado SSL detectado via Censys | Direto (HTTPS) |
| **Vulnerabilidade de Versão** | Banners de software identificados passivamente | A confirmar (Fase 03) |

---

## 🧰 Ferramentas Utilizadas

* **BGPView:** Mapeamento de ASN e Peers.
* **Shodan / Censys:** Consulta de snapshots de infraestrutura.
* **Google Dorks:** Mineração de dados indexados.
* **Whois / IPInfo:** Detecção de natureza do IP e ISP.

---

## 🧠 Conclusão da Inteligência de Rede

O reconhecimento passivo confirmou uma infraestrutura de **IP estático** exposta diretamente via ISP, sem camadas de WAF externas. A topologia de cascateamento sugere que o compromisso do Gateway de borda pode levar ao acesso total à sub-rede do laboratório.

**🚀 Próximo Passo:** [Fase 03 - Enumeração Ativa](./03_Enumeration.md)

---
> [!NOTE]
> Este documento encerra a fase de coleta de informações sem interação técnica direta com os ativos do alvo.