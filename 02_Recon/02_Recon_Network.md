🌐 RECON_NETWORK.md - Reconhecimento de Infraestrutura Externa

📖 Visão Geral

Esta etapa foca no Footprinting de Rede Passivo. O objetivo é mapear a presença da infraestrutura do alvo na internet sem disparar alertas de segurança (IDS/IPS). Diferente da Fase 02 (Física), aqui analisamos a "casca" digital: blocos de IP, ASN, certificados e serviços indexados por motores de busca de terceiros.

🛰️ 1. Inteligência de ASN e Roteamento (Backbone Analysis)

A análise partiu da identificação do provedor de serviços (ISP) para entender a topologia de borda.

ASN Identificado: 8167 (V Tal / Brasil Telecom).

Técnica: ASN Lookup & BGP Routing Analysis.

Ferramentas: BGPView, Whois, IPInfo.io.

Insight de Red Team: O ASN 8167 é um backbone de grande escala. A análise de vizinhança de rede (Neighboring IPs) foi realizada para identificar se o alvo utiliza um IP estático (comum em servidores de lab) ou um pool dinâmico residencial, o que dita a persistência dos payloads de C2 (Command & Control).

📡 2. Surface Mapping (Busca Passiva via Shodan/Censys)

Utilizando motores de busca que já possuem o "snapshot" da rede, mapeamos o que está exposto sem enviar um único pacote ao alvo.

A. Impressão Digital de Serviços (Fingerprinting)

Filtros Shodan: asn:8167 net:[Seu_Bloco_IP]

Identificação: Mapeamento de portas comuns (80, 443, 22, 3389) indexadas no último scan do Shodan.

Tecnologias Identificadas: Identificação de banners de servidores Nginx e Apache, permitindo prever a stack do laboratório sem interação direta.

B. Certificados e Identidade (Censys/CRT.sh)

Técnica: Certificate Transparency (CT) Logs.

Ferramentas: Censys Search, CRT.sh.

Descoberta: Através da query services.tls.certificates.leaf_data.subject.organization:*, foi possível localizar certificados SSL/TLS emitidos para subdomínios legados vinculados à identidade digital do alvo, expondo nomes de host que não constam em registros DNS atuais.

🛠️ 3. Google Dorking de Infraestrutura

Aplicação de operadores avançados para localizar documentos de configuração ou painéis de gerenciamento indexados.

Dork para Painéis: ip:[Seu_IP] site:login | site:admin

Dork para Arquivos: site:[Seu_Dominio] filetype:log | filetype:conf

Resultado: Localização de diretórios indexados que podem revelar versões de software antes mesmo da fase de Enumeração.

🧰 Ferramentas Utilizadas (100% Passivo)

Shodan: Consulta de serviços e dispositivos sem interação direta.

Censys: Análise de certificados e histórico de hosts.

ViewDNS.info** / IPInfo:** Histórico de DNS e detalhes de ASN.

BGPView: Mapeamento de peers e roteamento de rede.

Google Dorks: Mineração de dados indexados.

🧠 Conclusão da Inteligência de Rede

O reconhecimento de rede confirmou que o alvo opera sob uma infraestrutura de IP dinâmico, porém com vazamento de metadados em certificados TLS antigos. Isso permite que um atacante correlacione o IP efêmero a uma identidade fixa através de registros históricos de certificados.

Próximo Passo: Integrar estes dados com a Fase 03 (Enumeração) para validar quais dessas portas indexadas ainda estão abertas e quais versões exatas estão rodando "ao vivo".

Nota: Todas as consultas foram realizadas de forma anônima e passiva, respeitando a integridade do ambiente do alvo.
