# 🛰️ Fase 02: Reconhecimento Ativo & Geolocalização
![Status: Em Execução](https://img.shields.io/badge/Status-Em_Execu%C3%A7%C3%A3o-yellow?style=for-the-badge)
![Nível: Intermediário](https://img.shields.io/badge/N%C3%ADvel-Intermedi%C3%A1rio-blue?style=for-the-badge)
![MITRE: Reconnaissance](https://img.shields.io/badge/MITRE_ATT%26CK-TA0043-orange?style=for-the-badge)

## 📖 Visão Geral
Nesta etapa, o objetivo é validar os dados coletados na **Fase 01 (OSINT)** e realizar a transição da inteligência digital para a infraestrutura física e lógica do alvo. O foco aqui é a identificação de ativos vivos e o mapeamento do perímetro de rede.

---

## 🌐 1. Investigação de Infraestrutura: O Elo Histórico
A investigação partiu de um ponto de extremidade técnico (Pivoting) identificado em vazamentos de bases SQL anteriores.

### 🕵️‍♂️ Ponto de Acesso Identificado (Legado)
* **IP Exposto:** `187.6.181.16`
* **Hostname:** `187-6-181-16.3g.brasiltelecom.net.br`
* **ASN:** `8167` (V Tal Telecom / Brasil Telecom)
* **Localização Estimada (ISP):** `-30.1156, -51.1653`
* **Precisão:** `~500m`

> **🧠 Inteligência de Campo (OPSEC):** > Embora o IP aponte para uma localização em Porto Alegre, a análise de latência e metadados cruzados sugeriu um **Ponto de Acesso Dinâmico**. Em Red Teaming, classificar um IP como "Efêmero" evita o desperdício de recursos em ataques contra gateways que podem sofrer rotação a cada 24 horas.

---

## 📍 2. Reconhecimento Físico via Metadados (Pivoting)
Para superar a limitação do IP dinâmico, foi realizada a técnica de **Image Metadata Extraction (T1590.001)**.

### 📸 Extração de Coordenadas Reais
Através da análise de arquivos de mídia vinculados ao alvo, foram extraídos metadados **EXIF** que revelaram a localização estática e precisa do perímetro doméstico.

* **Técnica:** Forense de imagem via `ExifTool`.
* **Resultado:** Identificação do **Perímetro Estático** (Residência Real em Curitiba).
* **Valor Estratégico:** A divergência entre o IP (Porto Alegre) e a coordenada real (Curitiba) confirmou o deslocamento da persona, permitindo o planejamento do reconhecimento wireless no local correto.

---

## 📶 3. Mapeamento de Radiofrequência (Wireless Recon)
Com o perímetro físico delimitado, a operação focou no mapeamento do espectro de radiofrequência (RF) que serve o laboratório técnico.

* **Técnica:** Consulta passiva a bancos de dados de Wardriving (`WigLe.net`).
* **SSID Identificado:** `[MASCARADO]`
* **Protocolo de Segurança:** `WPA2-PSK (CCMP/AES)`.
* **Vetor de Ataque:** Identificação de vazamento de sinal (Signal Leakage) para áreas públicas, permitindo a captura de Handshakes sem a necessidade de intrusão física imediata.

> 🛡️ **Nota de Metodologia:**
> O processo de auditoria e ganho de acesso à rede sem fio identificada encontra-se detalhado em meu repositório especializado:
> 🔗 [**Projeto: Wireless Pentest - Auditoria de Redes Locais**] https://github.com/edenzafire/Portfolio_pentest/tree/main/09_Wireless

---

## 🏘️ 5. Mapeamento de Ativos e Topologia de Rede (Inventory)
Após o reconhecimento do perímetro externo, a investigação focou na identificação dos ativos que compõem o ecossistema do laboratório de simulação. Esta etapa é crucial para definir os pontos de entrada e mapear potenciais vetores de **Movimentação Lateral**.

### Tabela de Ativos Identificados

| Ativo | Endereço IP | Função Primária | Sistema Operacional | Portas/Serviços Identificados |
| :--- | :--- | :--- | :--- | :--- |
| **Attack Box** | `192.168.1.X` | C2 & Auditoria | Lubuntu (PenTest Suite) | N/A (Source Node) |
| **Web Server** | `192.168.1.10` | Hospedagem Lab | Linux (Kernel 5.x) | HTTP (80), HTTPS (443) |
| **Workstation** | `192.168.1.15` | Endpoint Usuário | Windows 10 (22H2) | SMB (445), RDP (3389) |
| **Mobile 01** | `192.168.1.20` | Persona Device | Android (v13/API 33) | ADB (5555), HTTP (8080) |
| **Mobile 02** | `192.168.1.25` | Persona Device | iOS (v16.x) | Apple Service Ports |

> **📝 Nota de Metodologia:**
> Os serviços identificados preliminarmente nesta fase (como servidores HTTP e protocolos de compartilhamento) foram agendados para a **Fase 03: Enumeração**, onde serão realizados testes de *banner grabbing*, identificação de versões exatas e varredura de vulnerabilidades conhecidas (CVEs).

---

## 🚀 6. Conclusão e Próximos Passos
O reconhecimento foi bem-sucedido em validar a infraestrutura lógica e física do alvo. A transição para a próxima fase focará em:
1. **Enumerar** a versão do servidor Apache no ativo `192.168.1.10`.
2. **Identificar** compartilhamentos SMB e versões de protocolos no Windows 10.
3. **Auditar** portas de depuração abertas nos dispositivos móveis.

---
