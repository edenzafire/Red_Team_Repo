# 🛰️ Fase 02: Reconhecimento Ativo (Transição para Enumeração)

**Status:** Em Execução  
**Nível:** Intermediário  
**MITRE ATT&CK:** Reconnaissance (TA0043) → Preparação para Discovery / Enumeration

## 📖 Visão Geral
Nesta fase, o objetivo foi validar e correlacionar informações obtidas durante o Reconhecimento Passivo (OSINT), promovendo a transição controlada da inteligência digital para a infraestrutura física e lógica associada ao alvo.

Embora esta etapa ainda seja classificada como Reconhecimento, algumas atividades já envolvem interação técnica limitada, caracterizando um **Reconhecimento Ativo**, que antecede formalmente a Fase de Enumeração.

O foco principal foi:
* Validar a existência de ativos reais;
* Identificar possíveis pontos de presença física;
* Mapear o perímetro externo antes de qualquer enumeração profunda de serviços.

---

## 🌐 1. Investigação de Infraestrutura – Correlação Histórica
A investigação teve início a partir de um ponto técnico de **pivoting**, identificado previamente em vazamentos históricos de bases SQL associados à persona analisada. Esse ponto serviu como elo inicial entre a presença digital e a infraestrutura de conectividade utilizada pelo alvo.

### 🕵️‍♂️ Ponto de Acesso Identificado (Infraestrutura Legada)
* **IP Exposto:** `187.6.181.16`
* **Hostname:** `187-6-181-16.3g.brasiltelecom.net.br`
* **ASN:** `8167` (V Tal Telecom / Brasil Telecom)
* **Localização Estimada (ISP):** `-30.1156, -51.1653`
* **Precisão Aproximada:** `~500 metros`

### 🧠 Inteligência Operacional (OPSEC)
Embora o endereço IP indicasse geolocalização em Porto Alegre, a análise cruzada de latência, histórico de alocação ASN e características do hostname sugeriu tratar-se de um IP dinâmico e efêmero.

> **Nota OPSEC:** Em operações de Red Team, classificar corretamente um IP como dinâmico evita o desperdício de recursos em tentativas de exploração contra gateways que podem sofrer rotação frequente (ex.: a cada 24h).

---

## 📍 2. Reconhecimento Físico via Metadados (Pivoting Passivo)
Diante da limitação imposta pelo IP dinâmico, foi aplicada a técnica de extração passiva de metadados de arquivos de mídia associados ao alvo, conforme a técnica **MITRE T1590.001 – Gather Victim Network Information: IP Addresses** (correlação indireta).

### 📸 Extração de Coordenadas Reais
A análise de metadados EXIF revelou coordenadas geográficas estáticas e precisas, associadas ao perímetro residencial real.

* **Técnica:** Forense de imagem com `ExifTool`
* **Resultado:** Identificação do perímetro físico real (**Curitiba – PR**)
* **Valor Estratégico:** A divergência entre a localização estimada via IP (Porto Alegre) e as coordenadas reais (Curitiba) confirmou o deslocamento da persona, permitindo o direcionamento correto das etapas seguintes de reconhecimento físico e wireless.

---

## 📶 3. Reconhecimento Wireless Passivo (RF Mapping)
Com o perímetro físico delimitado, foi realizado o mapeamento passivo do espectro de radiofrequência, sem associação ou interação direta com a rede.

* **Técnica:** Consulta passiva a bases públicas de wardriving ([Wigle.net](http://Wigle.net))
* **SSID Identificado:** `[MASCARADO]`
* **Protocolo de Segurança:** `WPA2-PSK (CCMP/AES)`

### 🎯 Observação Estratégica
Foi identificada propagação de sinal para áreas públicas, caracterizando **Signal Leakage**, o que potencialmente permitiria a captura de handshakes sem intrusão física imediata.

> **⚠️ Nota Metodológica:** Qualquer tentativa de associação, captura de handshake ou auditoria ativa da rede wireless caracteriza Enumeração / Ataque e é tratada separadamente.
> 🔗 **Projeto correlato:** [Wireless Pentest – Auditoria de Redes Locais]

---

## 🏘️ 4. Mapeamento Inicial de Ativos (Visão de Inventário)
Com base no reconhecimento físico e lógico preliminar, foi possível identificar os ativos que compõem o ambiente do laboratório de simulação, permitindo o planejamento da fase seguinte.

**⚠️ Importante:** A identificação detalhada de serviços, versões e portas é tratada formalmente na **Fase 03 – Enumeração**.

| Ativo        | Endereço IP     | Função Primária        | Sistema Operacional           |
|-------------|------------------|------------------------|--------------------------------|
| Attack Box  | 192.168.1.X      | C2 & Auditoria         | Lubuntu (Pentest Suite)        |
| Web Server  | 192.168.1.10     | Hospedagem de Lab      | Linux (Kernel 5.x)             |
| Workstation | 192.168.1.15     | Endpoint Usuário       | Windows 10 (22H2)              |
| Mobile 01   | 192.168.1.20     | Dispositivo Persona    | Android 13 (API 33)            |
| Mobile 02   | 192.168.1.25     | Dispositivo Persona    | iOS 16.x                       |

---

## 🛠️ 05 - Ferramentas Utilizadas
* **Shodan** (consulta passiva de serviços expostos)
* **Censys** (correlação de infraestrutura)
* **ExifTool** (extração de metadados)
* **[Wigle.net](http://Wigle.net)** (wardriving passivo)
* **Whois / ASN Lookup**
* 🔗 [**Link para a pasta de evidências (evidence)**](./evidence)

---

## 📝 Nota de Metodologia
Os serviços e protocolos associados a esses ativos (HTTP, SMB, RDP, ADB, entre outros) não foram enumerados nesta fase. Essas atividades foram explicitamente planejadas para a **Fase 03 – Enumeração**, onde serão aplicadas técnicas como:
* **Banner grabbing**
* **Identificação de versões exatas**
* **Correlação com vulnerabilidades conhecidas (CVEs)**

---

## 🚀 5. Conclusão e Próximos Passos
O Reconhecimento Ativo foi bem-sucedido em validar a infraestrutura lógica e física associada ao alvo, reduzir incertezas geográficas e delimitar o perímetro correto para operações ativas.

**A próxima fase (Enumeração) terá como foco:**
1. Identificação precisa da versão do servidor web no ativo `192.168.1.10`;
2. Enumeração de compartilhamentos e protocolos SMB no endpoint Windows;
3. Validação de serviços de depuração expostos em dispositivos móveis.
