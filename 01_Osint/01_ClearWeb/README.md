# 🔍 Estudo de Caso: Auto-OSINT e Pegada Digital Legada

**Mapeamento completo da superfície de ataque digital de um indivíduo a partir de dados vazados entre 2018–2023**

[![OSINT](https://img.shields.io/badge/Técnica-OSINT-blue)](https://github.com/edenzafire/Portfolio_pentest/tree/main/Clear_Web)
[![Python](https://img.shields.io/badge/Script-Python-yellow)](https://github.com/edenzafire/Portfolio_pentest/blob/main/Scripts/scripts_osint/bd_lookup.py)
[![Maltego](https://img.shields.io/badge/Tool-Maltego_CE-lightgrey)](https://www.maltego.com/)
[![Status](https://img.shields.io/badge/Status-Concluído-green)]()

**Data:** dezembro 2025
**Autor:** Zafire Daniel  

## 📌 Visão Geral
Demonstração realista e **100% ética** de como vazamentos antigos podem ser correlacionados para reconstruir identidade digital, credenciais reutilizadas e localização histórica.

> **Aviso Legal**: Todos os dados reais foram mascarados/ofuscados. Este é um exercício de Red Team simulado para fins educacionais e portfólio.

## 🎯 Objetivo
Mostrar o impacto duradouro de brechas de segurança antigas e como um atacante pode:
- Realizar **doxing passivo**
- Preparar ataques de **credential stuffing**
- Pivotar para **geolocalização precisa**

## 🛠 Metodologia e Ferramentas
Alinhado ao **MITRE ATT&CK – Reconnaissance (TA0043)**

| Ferramenta              | Uso Principal                          |
|-------------------------|----------------------------------------|
| Holehe                  | Verificação de registros em serviços   |
| Have I Been Pwned       | Consulta de breaches                   |
| BreachDirectory API     | Busca automatizada (script próprio)    |
| Maigret / Sherlock      | Rastreamento de usernames              |
| Maltego CE              | Visualização de relações               |
| Python (pandas, regex)  | Normalização e parsing de dados        |

📂 **Script principal**: [bd_lookup.py](https://github.com/edenzafire/Portfolio_pentest/blob/main/Scripts/scripts_osint/bd_lookup.py)
## 👀 Demonstração em vídeo

🎥 Demonstração da evidência — vídeo:

👉 [Assista ao vídeo](https://raw.githubusercontent.com/edenzafire/Red_Team_Repo/main/01_Osint/01_ClearWeb/evidence/EvidenceHibp.mp4)


## 📊 Resultados em Números
- **10+ breaches** identificados (2018–2023)
- **~58 plataformas** com username consistente
- **2 pontos geográficos** triangulados com precisão ~500m
- Hashes expostos: SHA1, PBKDF2, bcrypt

## 🔗 Relatórios Detalhados
Explore cada pivô de análise:

- [📧 Análise de E-mail e Breaches](https://github.com/edenzafire/Red_Team_Repo/blob/main/01_Osint/01_ClearWeb/01_Email_Analysis.md)
- [👤 Consistência de Usernames](https://github.com/edenzafire/Portfolio_pentest/blob/main/01_Osint/01_ClearWeb/02_Username_Consistency.md)
- [📱 Footprint em Redes Sociais](https://github.com/edenzafire/Portfolio_pentest/blob/main/01_Osint/01_ClearWeb/03_Social_Footprint.md)
- [🌍 Pivotagem Geográfica e Artefatos de Rede](https://github.com/edenzafire/Portfolio_pentest/blob/main/01_Osint/01_ClearWeb/04_Geo_Pivoting.md)
- [☎ Análise Telefônica](https://github.com/edenzafire/Portfolio_pentest/blob/main/01_Osint/01_ClearWeb/05_Phone_Analysis.md)


## 🛡 Técnicas MITRE ATT&CK Mapeadas
| ID            | Técnica                              | Aplicação no Projeto                     |
|---------------|--------------------------------------|------------------------------------------|
| T1589.002     | Gather Victim Identity Information   | Coleta de nome, nascimento, cidades      |
| T1593.001     | Search Open Technical Databases      | Consulta em bases de vazamentos          |
| T1592.005     | Gather Victim Digital Network Info   | Device IDs, tokens Firebase, IP histórico|

## 💡 Lições Aprendidas e Recomendações
- Reutilização de senhas/hashes é o maior vetor mesmo anos depois
- Usernames consistentes são o "fio condutor" perfeito para doxing
- Apps de delivery e restaurantes vazam geolocalização absurdamente precisa
- **Recomendações práticas**: MFA hardware, higienização LGPD, variação de usernames

## 🖼 Teaser Visual
![Maltego Graph Teaser](https://via.placeholder.com/800x450.png?text=Maltego+Graph+-+Relacionamentos+OSINT)  
*(Em breve: screenshot real do grafo no Maltego com entidades mascaradas)*

---

**Projeto em evolução** – Próximos módulos: Recon Técnico, Enumeração de Subdomínios, Wi-Fi Attacks e CTFs.

⭐ Se curtiu, deixa uma star no repo!
