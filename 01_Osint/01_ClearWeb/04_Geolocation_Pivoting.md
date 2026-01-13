# Relatório OSINT - Pivotagem Geográfica

**Análise de Coordenadas e Artefatos de Rede**  
**Data:** 2025  
**Autor:** Zafire Daniel  

## Achados Geográficos (Leaks 2019)
- Precisão aproximada de ~500m identificada em leak Habibs
- Segundo ponto corroborado em leak James Delivery (área metropolitana)
- Cidades identificadas: C****** – PR (atual) e P**** A***** – RS (histórico)

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

- ** Prints e Evidências no seguinte link**


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
