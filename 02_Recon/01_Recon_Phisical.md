# 🛰️ Fase 02: Reconhecimento Ativo & Físico (Transição para Enumeração)

![Status](https://img.shields.io/badge/Fase-02-blue?style=for-the-badge&logo=target)
![Mode](https://img.shields.io/badge/Type-Active_Physical_Recon-orange?style=for-the-badge)
![Security](https://img.shields.io/badge/OpSec-Medium-yellow?style=for-the-badge)

---

## 📖 Visão Geral
Nesta fase, o objetivo foi validar e correlacionar informações obtidas durante o Reconhecimento Passivo (OSINT), promovendo a transição controlada da inteligência digital para a infraestrutura física e lógica associada ao alvo. 

O foco evoluiu de "quem é o alvo" para **"onde o alvo opera e como posso chegar perto"**, mapeando o perímetro físico, vetores de radiofrequência (RF) e potenciais pontos de intrusão local (Physical Attack Surface).

---

## 🌐 1. Investigação de Infraestrutura – Correlação Histórica
A investigação utilizou técnicas de **pivoting** técnico para ligar o rastro digital a um ponto de presença de rede real.

### 🕵️‍♂️ Ponto de Acesso Identificado (Infraestrutura Legada)
* **IP Exposto:** `187.6.181.16`
* **Hostname:** `187-6-181-16.3g.brasiltelecom.net.br`
* **ASN:** `8167` (V Tal Telecom / Brasil Telecom)
* **Localização ISP Estimada:** Porto Alegre - RS

> [!CAUTION]
> **Análise OPSEC:** Identificado como IP dinâmico e efêmero (Mobile/CGNAT). Embora tenha baixa confiabilidade para persistência de longo prazo, serviu como o "primeiro nó" para identificar o provedor de serviços (ISP) primário e a região de interesse.

---

## 📍 2. Reconhecimento Físico e Geográfico (Geolocalização de Precisão)
Utilizando a técnica **MITRE T1590.001**, realizamos a extração de metadados para quebrar a máscara do IP dinâmico e localizar o perímetro operacional real.

### 📸 Extração de Coordenadas Reais (Forense de Imagem)
* **Técnica:** Análise de metadados EXIF em ativos de mídia (fotos de laboratório postadas em redes sociais).
* **Localização Confirmada:** **Curitiba – PR** (Perímetro Urbano).
* **Valor Estratégico:** A divergência entre a geolocalização do ISP (RS) e as coordenadas reais (PR) confirmou o deslocamento do alvo, permitindo o direcionamento correto das etapas de reconhecimento wireless e proximidade.

> [!TIP]
> **Insight Forense:** O uso do script `metadata_extractor.py` (disponível na pasta /scripts) permitiu a automação desta coleta, convertendo tags de GPS brutas em coordenadas decimais prontas para mapeamento.

---

## 📶 3. Reconhecimento de Radiofrequência (RF Mapping)
Com o perímetro físico delimitado, mapeamos o espectro de sinal para identificar vetores de entrada sem fio e dispositivos de proximidade.

### 📡 3.1. Wireless Passivo (WiFi)
* **SSID Identificado:** `[MASCARADO_LAB]`
* **Segurança:** `WPA2-PSK (CCMP/AES)`
* **Vulnerabilidade:** **Signal Leakage** identificado. O sinal propaga-se ~15 metros além do perímetro físico.

> [!IMPORTANT]
> A propagação de sinal para via pública permite a tentativa de captura de *handshakes* sem a necessidade de invasão de propriedade, reduzindo drasticamente o risco de detecção física.

### 🔹 3.2. Proximidade Bluetooth (BLE Recon)
* **Vetor:** Identificação de periféricos (teclados, mouses, wearables) associados à persona.
* **Risco:** Dispositivos Bluetooth sem autenticação robusta permitem o mapeamento de presença física (saber se o alvo está no local) e possíveis ataques de *BlueSnarfing*.

---

## 🏗️ 4. Análise de Perímetro (Physical Attack Surface)
O Reconhecimento Físico avalia as barreiras do "mundo real" que protegem os ativos lógicos.

* **Câmeras de Segurança:** Busca por câmeras IP expostas (Dorks no Shodan/Censys). Nenhuma câmera exposta diretamente, sugerindo boa segmentação.
* **Pontos de Entrada:** Identificação visual de portaria para possíveis cenários de **Tailgating**.
* **Hardware Implant Zone:** Áreas de circulação comum adequadas para dispositivos velados (ex: *BadUSB* ou *WiFi Pineapple*).



---

## 🏘️ 5. Mapeamento Inicial de Ativos (Inventário de Lab)

| Ativo | Endereço IP (Provável) | Sistema Operacional | Vetor de Descoberta |
| :--- | :--- | :--- | :--- |
| **Attack Box** | `192.168.1.X` | Lubuntu (Pentest Suite) | Observação de Tráfego |
| **Web Server** | `192.168.1.10` | Linux (Kernel 5.x) | DNS Leak / Histórico SQL |
| **Workstation** | `192.168.1.15` | Windows 10 (22H2) | Hostname em Metadados |
| **Mobile 01** | `192.168.1.20` | Android 13 | BSSID Correlation |
| **Mobile 02** | `192.168.1.25` | Android 12 | BLE Proxy Discovery |

---

## 🧰 06 - Ferramentas Utilizadas
* **ExifTool:** Extração de coordenadas GPS.
* **Wigle.net:** Mapeamento geolocalizado de redes WiFi.
* **Shodan / Censys:** Busca por serviços e câmeras.
* **Google Earth Pro:** Análise de visibilidade e topografia.
* 🔗 [**Acessar pasta de evidências (Evidences)**](https://github.com/edenzafire/Portfolio_pentest/tree/main/02_Recon/evidences)

---

## 🚀 7. Conclusão e Próximos Passos
O Reconhecimento Físico validou que o alvo possui um perímetro híbrido vulnerável a ataques de proximidade. O **Signal Leakage** WiFi e a descoberta de dispositivos **Bluetooth** são os vetores de maior probabilidade de sucesso para a intrusão inicial.

**Próxima Etapa:** Iniciar a [Fase 03 – Enumeração](./03_Enumeration.md) focando em identificação de banners e serviços ativos.