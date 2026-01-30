# Relatório OSINT - Geolocation & Pivoting (Mascarado)
**Rastreamento de Movimentação e Infraestrutura Técnica**

## Resumo Executivo
Através do pivoting de dados técnicos encontrados em vazamentos SQL, foi possível converter um e-mail em coordenadas geográficas precisas e identificadores civis.

## Vetores Técnicos e Pivoting
| Atributo | Dado Mascarado | Fonte Original |
| :--- | :--- | :--- |
| **Coordenadas** | -30.1***, -51.1*** (Precisão 500m) | Habibs SQL Dump |
| **Endereço IP** | 187.6.***.*** (V Tal Telecom) | Log de Acesso App |
| **Identificador** | CPF: 110.1**.***-92 (Situação Regular) | Consulta RFB (via Leak) |
| **Device ID** | Token Firebase: APA91b... (parcial) | James Delivery SQL |

## Análise de Pivoting
1. **Email -> App Delivery:** Revelou endereço IP e geolocalização histórica.
2. **IP -> ASN:** Identificou o provedor de internet e a região metropolitana.
3. **Data de Nasc. + Nome -> CPF:** Permitiu a validação da identidade real junto a órgãos governamentais.

## Avaliação de Risco Físico
A precisão das coordenadas (-30.1156, -51.1653) demonstra o risco de **Doxxing** e vigilância física baseada em metadados de aplicativos de terceiros.


## Achados Geográficos (Leaks 2019)
- Precisão aproximada de ~500m identificada em leak Habibs
- Segundo ponto corroborado em leak James Delivery (área metropolitana)
- Cidades identificadas: Araucária – PR (atual) e P**** A***** – RS (histórico)

## Artefato de Rede Isolado
- **IP Histórico:** `187.6.181.16`
- **ASN:** AS27699 (Telefônica Brasil / VIVO)
- **Geolocalização:** Curitiba – PR (2019)
- **Técnica:** Pivotagem para mapeamento passivo (Shodan, Censys, passive DNS)

## Pivotagem via Metadados de Imagem (Análise EXIF)
- **Artefato analisado:** Foto de perfil pública (`GrD-WxC0_400x400.jpg`) extraída do perfil X/Twitter (@R********* – User ID: 18********056******)
- **Análise inicial:** Nenhum dado GPS presente nos metadados originais (confirmado via ExifTool v12.76)
- **Coordenadas identificadas:**
  - Latitude: 25° 35' 35.15" S
  - Longitude: 49° 24' 36.81" W
  - Altitude: 897 m acima do nível do mar
  - Datum: WGS-84
- **Localização correlacionada:** Área urbana central de Araucária – PR
- **Precisão alcançada:** ~100m (elevação significativa em relação aos leaks anteriores)
- **Correlação com achados prévios:** Compatível com IP histórico (Curitiba/PR metropolitana) e padrões de residência identificados

* 🔗 [**Link para a pasta de evidências (evidence)**]( https://github.com/edenzafire/Red_Team_Repo/tree/main/02_Recon/evidences/exif )



## Relevância em Pentest / OSINT
- Permite refinar padrões de residência, deslocamento e consumo do alvo
- Metadados EXIF em fotos públicas representam vetor comum de vazamento de geolocalização
- Triangulação cruzada (leaks + IP histórico + EXIF) eleva precisão do perfil geográfico
- Ponto de partida para recon técnico adicional (busca por dispositivos IoT, câmeras públicas ou infraestrutura exposta na região)

## Risco Associado
**Alto** → Exposição precisa de localização histórica ou atual facilita ataques direcionados, como:
- Phishing hiperlocalizado
- Engenharia social baseada em rotina
- Reconhecimento físico (em cenários extremos)

---

_*Aviso Geral:* Este portfólio contém demonstrações técnicas com dados simulados/fictícios exclusivamente para fins educacionais e ilustrativos. Nenhum dado real sensível foi exposto ou manipulado de forma indevida._
