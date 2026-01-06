# 🛰️ Fase 02: Reconhecimento Ativo & Geolocalização
![Status: Em Execução](https://img.shields.io/badge/Status-Em_Execu%C3%A7%C3%A3o-yellow?style=for-the-badge)
![Nível: Intermediário](https://img.shields.io/badge/N%C3%ADvel-Intermedi%C3%A1rio-blue?style=for-the-badge)
![MITRE: Reconnaissance](https://img.shields.io/badge/MITRE_ATT%26CK-TA0043-orange?style=for-the-badge)

## 📖 Visão Geral
Nesta etapa, o objetivo é validar os dados coletados na **Fase 01 (OSINT)** e realizar a transição da inteligência digital para a infraestrutura física e lógica do alvo. O foco aqui é a identificação de ativos vivos e o mapeamento do perímetro de rede.

---

## 🌐 1. Investigação de Infraestrutura: O Elo Histórico
A partir dos vazamentos identificados anteriormente, isolamos um ponto de extremidade técnico para análise de conectividade.

### 🕵️‍♂️ Ponto de Acesso Identificado (Legado)
* **IP Exposto:** `187.6.181.16`
* **Hostname:** `187-6-181-16.3g.brasiltelecom.net.br`
* **ASN:** `8167` (V Tal Telecom / Brasil Telecom)
* **Localização Estimada (ISP):** `-30.1156, -51.1653`
* **Precisão:** `~500m`

> **🧠 Análise do Analista:** Após investigação profunda, constatou-se que este registro representava um **acesso temporário (em trânsito)**. Embora o dado seja real, ele não indicava o perímetro de residência fixa do alvo, sendo classificado inicialmente como um "ponto efêmero".

---

## 📍 2. Reconhecimento Físico via Metadados (Pivoting)
Para superar a limitação do IP dinâmico, foi realizada a técnica de **Image Metadata Extraction (T1590.001)**.

### 📸 Extração de Coordenadas Reais
Através da análise de arquivos de mídia vinculados ao alvo, foram extraídos metadados **EXIF** que revelaram a localização estática e precisa do perímetro doméstico.

* **Técnica:** Extração de GPS via **ExifTool**.
* **Resultado:** Identificação da residência real do alvo, permitindo o mapeamento do sinal de rede sem fio (Wi-Fi).

---

## 📶 3. Identificação de Perímetro Wireless
Com a localização física confirmada, a investigação evoluiu para a identificação da rede que serve de gateway para o laboratório técnico.

* **Ação:** Consulta ao banco de dados **WigLe.net** utilizando as coordenadas extraídas.
* **SSID Identificado:** [CONFIDENCIAL]
* **Segurança:** WPA2-PSK.

> 🛡️ **Nota de Metodologia:**
> O processo de auditoria e ganho de acesso à rede sem fio identificada encontra-se detalhado em meu repositório especializado:
> 🔗 [**Projeto: Wireless Pentest - Auditoria de Redes Locais**](SEU_LINK_AQUI)

---

## 🏘️ 4. Mapeamento da Rede Interna (Home Lab)
Uma vez estabelecida a presença no perímetro, o Recon focou na descoberta de ativos dentro da sub-rede local.

| Ativo | IP Local | Função | SO |
| :--- | :--- | :--- | :--- |
| **Attack Box** | `192.168.1.X` | Auditoria | Lubuntu |
| **Alvo Principal** | `192.168.1.10` | Web Server | **Apache** |
| **Workstation** | `192.168.1.15` | Produtividade | Windows 10 |

**Próximo Passo:** Início do **Fingerprinting** detalhado no servidor Apache para identificação de vetores de entrada.
