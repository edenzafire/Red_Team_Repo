# Relatório OSINT - Pivotagem Geográfica
**Análise de Coordenadas e Artefatos de Rede**
**Data:** 08/01/2026  
**Autor:** Zafire Daniel  

## Achados Geográficos (de leaks 2019)
- Precisão ~500m em leak Habibs
- Segundo ponto em leak James Delivery (área metropolitana)
- Cidades identificadas: C****** – PR (atual) e P**** A***** – RS (histórico)

## Artefato de Rede Isolado
- **IP Histórico:** 187.6.181.16
- **ASN:** AS27699 (Telefônica Brasil / VIVO)
- **Geolocalização:** Curitiba – PR (2019)
- **Técnica:** Pivotagem para mapeamento passivo (Shodan, Censys, pDNS)

## Relevância em Pentest
- Permite identificar padrões de residência e consumo
- Ponto de partida para recon técnico (busca por infraestrutura exposta)
- Triangulação cruzada aumenta precisão do perfil do alvo

## Risco
Alto → Exposição precisa de localização histórica facilita ataques direcionados.
