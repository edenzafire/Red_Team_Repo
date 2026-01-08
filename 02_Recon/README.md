# 🛰 Fase 02: Reconhecimento Ativo & Expansão de Superfície de Ataque

![Status: Parcialmente Concluído](https://img.shields.io/badge/Status-Parcialmente_Conclu%C3%ADdo-yellowgreen?style=for-the-badge)
![Nível: Intermediário](https://img.shields.io/badge/N%C3%ADvel-Intermedi%C3%A1rio-blue?style=for-the-badge)
![MITRE: Reconnaissance](https://img.shields.io/badge/MITRE_ATT%26CK-TA0043-orange?style=for-the-badge)
![Foco: Red Teaming](https://img.shields.io/badge/Foco-Red_Teaming-critical?style=for-the-badge&logo=kali-linux&logoColor=white)

**Data:** Janeiro 2026  
**Autor:** Zafire Daniel  

## 📖 Visão Geral
Transição estratégica da inteligência passiva (**Fase 01 - OSINT**) para reconhecimento direcionado e ativo. Aqui transformamos dados vazados (e-mails, usernames, IPs históricos) em ativos técnicos reais: localização física, perímetro wireless e mapeamento da rede interna.

> **Objetivo Principal:** Expandir a superfície de ataque identificada via OSINT, validando achados e descobrindo vetores prioritários para enumeração.

## 🌉 Ponte de Inteligência: Do Dado OSINT ao Ativo Técnico
| 📥 Output da Fase 01 (OSINT)      | ⚙ Processo de Recon Ativo                  | 📤 Resultado Obtido                          |
|-----------------------------------|---------------------------------------------|---------------------------------------------|
| IP histórico vazado (2019)        | Análise de persistência + hostname lookup   | Classificado como ponto efêmero (dinâmico)  |
| Metadados vinculados ao alvo      | Extração EXIF (T1590.001)                   | Coordenadas precisas da residência (<10m)   |
| Coordenadas geográficas           | Consulta Wigle.net (T1593.002)              | SSID e criptografia da rede doméstica       |
| Presença confirmada na LAN        | Descoberta passiva/ativa de hosts           | 3 ativos vivos mapeados (incl. web server)  |

## 🛠 Stack Tecnológica & Técnicas Aplicadas
Alinhado ao **MITRE ATT&CK - Reconnaissance (TA0043)**

| Técnica MITRE         | Ferramentas Utilizadas                  | Aplicação no Projeto                          |
|-----------------------|-----------------------------------------|-----------------------------------------------|
| T1590.001             | ExifTool                                | Extração de GPS de imagens vinculadas         |
| T1593.002             | Wigle.net                               | Mapeamento de redes Wi-Fi por coordenadas     |
| T1595 / T1046         | Nmap (inicial), arp-scan                | Descoberta de hosts e fingerprinting básico   |
| Planejado: T1590      | Amass, Subfinder, DNSRecon              | Enumeração de subdomínios (domínios de e-mail)|
| Planejado: T1593      | TruffleHog, GitHub Dorks                | Busca de segredos em repositórios públicos    |

## 📊 Achados Principais (Mascarados)
- Localização física precisa obtida sem interação direta com o alvo
- Rede wireless doméstica identificada (WPA2-PSK AES)
- Sub-rede interna mapeada: Gateway, Attack Box, Web Server Apache (192.168.1.10), Workstation Windows
- Banner HTTP exposto → versão Apache identificada (vetor prioritário)

## 🔗 Módulos Detalhados
- [🌍 01_Recon_Physical.md](01_Recon_Physical.md) → Pivot geográfico via EXIF + Wigle
- [🏠 02_Recon_Network.md](02_Recon_Network.md) → Mapeamento da LAN e fingerprinting inicial
- [📂 Evidências](evidence/) → Screenshots, outputs ExifTool, banners, etc.

## 🖼 Teaser Visual
![Exemplo EXIF + Wigle](evidence/teaser_geo.png)  
*(Screenshot real mascarado do fluxo EXIF → coordenadas → consulta Wigle)*

## Próximos Passos
- Expansão para recon externo (subdomínios, serviços expostos)
- Scanning profundo com Nmap (scripts NSE)
- Transição para **Fase 03: Enumeração & Vulnerability Research**

---

📫 **Quer ver o fluxo completo?** Confira a [Fase 01 - OSINT](../Clear_Web/) ou entre em contato via LinkedIn: [SEU_LINK_AQUI]

⭐ Se o portfólio está te ajudando, deixa uma star no repo!
