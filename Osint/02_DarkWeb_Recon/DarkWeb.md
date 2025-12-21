[![GitHub](https://img.shields.io/badge/GitHub-Repositorio-blue?logo=github)](https://github.com/edenzafire/Portfolio_pentest)
# Dark Web Reconnaissance - Demonstração OSINT

**Autor:** Zafire Daniel  
**Data:** 21 de Dezembro de 2025  
**Versão:** 1.1  

Este relatório demonstra uma abordagem ética e técnica para reconhecimento na dark web no âmbito de Open Source Intelligence (OSINT). O foco reside no monitoramento de ameaças cibernéticas, com ênfase em potenciais exposições de dados associados a domínios brasileiros (.br). Todos os exemplos e resultados são baseados em simulações fictícias, com dados mascarados para preservar a privacidade e conformidade legal.

## Objetivo

- Executar coleta anônima de inteligência via Tor em fontes públicas.
- Extrair e analisar indicadores de compromisso (IOCs) de forma responsável.
- Aplicar anonimização automática para demonstração segura.
- Fornecer insights acionáveis para estratégias de threat intelligence defensiva.

## Metodologia

### Ambiente Técnico
- **Plataforma:** Whonix 17+ configurado em VirtualBox, garantindo anonimato total através de isolamento de rede e roteamento Tor.
- **Acesso à Dark Web:** Proxy SOCKS5 na porta 9050, com renovação dinâmica de circuitos via biblioteca `stem` para mitigar riscos de rastreamento.
- **Script Personalizado:**  
  📂 [Pasta completa de Scripts OSINT](https://github.com/edenzafire/Portfolio_pentest/tree/main/Scripts/scripts_osint)  
  📄 [darkweb_monitor_masked_v2.py](https://github.com/edenzafire/Portfolio_pentest/blob/main/Scripts/scripts_osint/darkweb_monitor_masked_v2.py) – Versão ética com anonimização automática de IOCs (Python 3.11).

  Dependências principais: `requests`, `beautifulsoup4`, `pysocks`, `stem`.  
  Funcionalidades chave: Crawling restrito (profundidade máxima 2), delays aleatórios (8-18 segundos) e mascaramento regex automático.

- **Fontes de Dados:** Motores de busca éticos na dark web (Ahmia, Torch, DuckDuckGo Onion).
- **Parâmetros de Busca:** Keywords direcionadas: ".br", "gov.br", "vazamento brasil", "breach .com.br", "exposição CPF".

### Exemplo de Execução
```bash
python3 darkweb_monitor_masked_v2.py \
  --url "http://juhanurmihxlp77nkq76byazcldy2hlmovfu2epvl5ankdibsot4csyd.onion/search/?q=.br+breach+2025" \
  --keywords ".br" "vazamento" "leak brasil" "gov.br" "CPF exposto" \
  --max-depth 2 \
  --output recon_br_simulado.json

## Resultados ( Mascarados)

Páginas Analisadas: Aproximadamente 25 (crawling até profundidade 2, com otimização para evitar sobrecarga).
Menções Relevantes: 5 páginas fictícias com potenciais exposições.
IOCs Extraídos (Mascarados):

Emails: 12 (ex: us****@ex****.com.br, ad***@go****.br, fi****@ba****.com.br, cl****@em****.gov.br, se****@se****.com, jo****@pr****.br, ma****@co****.com.br, re****@fi****.gov.br, ti****@in****.br, va****@co****.com, wi****@te****.br, zo****@su****.com.br).

CPFs: 8 (ex: ***.***.***-**, ***.***.***-**, ***.***.***-**, ***.***.***-**, ***.***.***-**, ***.***.***-**, ***.***.***-**, ***.***.***-**).

Combos de Credenciais: 6 (ex: us****@ex****.com.br:senha1234, ad***@go****.br:acesso2025, fi****@ba****.com.br:passbr, cl****@em****.gov.br:govaccess, se****@se****.com:secure123, jo****@pr****.br:prbr2024).

## Exemplo de Saída  (JSON Mascarado):

[
  {
    "url": "http://simulado_forum.onion/thread-breaches-brasil-2025",
    "depth": 1,
    "found_keywords": [".br", "vazamento", "gov.br"],
    "context": "Discussão sobre exposição recente em domínio gov.br: menções a combos como us****@ex****.com.br:senha1234 e CPFs como ***.***.***-**.",
    "emails": ["us****@ex****.com.br", "ad***@go****.br"],
    "cpfs": ["***.***.***-**", "***.***.***-**"],
    "hashes": ["[HASH_MASCARADO]", "[HASH_MASCARADO]"],
    "combos": ["us****@ex****.com.br:senha1234", "ad***@go****.br:acesso2025"]
  },
  {
    "url": "http://simulado_market.onion/listing-leaks-financeiro",
    "depth": 2,
    "found_keywords": ["leak brasil", "CPF exposto"],
    "context": "Listagem de dados financeiros vazados: emails como fi****@ba****.com.br e hashes [HASH_MASCARADO].",
    "emails": ["fi****@ba****.com.br", "cl****@em****.gov.br"],
    "cpfs": ["***.***.***-**", "***.***.***-**"],
    "hashes": ["[HASH_MASCARADO]", "[HASH_MASCARADO]"],
    "combos": ["fi****@ba****.com.br:passbr", "cl****@em****.gov.br:govaccess"]
  }
]

## Análise e Insights

Padrões Identificados: Simulações indicam reutilização frequente de credenciais em breaches fictícios, com foco em setores sensíveis como governamental e financeiro no Brasil. Observa-se aumento hipotético de exposições pós-2023, possivelmente ligado a ciberataques direcionados.
Riscos Associados: Exposição de IOCs pode levar a pivoteamento (ex: email vazado usado para ataques de spear-phishing). No contexto brasileiro, conformidade com LGPD é crítica.
Eficiência da Abordagem: O script processou dados com latência mínima, garantindo anonimato e escalabilidade para monitoramento corporativo.

## Limitações

Limitado a fontes públicas indexadas – não abrange conteúdos privados ou não indexados.
Resultados fictícios para fins demonstrativos; em cenários reais, validar com ferramentas complementares como Maltego.
Dependência de qualidade dos motores de busca, com potencial ruído em queries amplas.

## Recomendações Estratégicas

Para Indivíduos: Adote autenticação multifator (2FA/MFA), gerenciadores de senhas robustos (ex: Bitwarden) e monitore regularmente em plataformas como Have I Been Pwned.
Para Organizações: Integre monitoramento automatizado da dark web em SOCs, realize treinamentos em cibersegurança e implemente políticas de responsible disclosure para exposições detectadas.
Melhorias Técnicas: Expanda o script para alertas em tempo real (ex: integração com SIEM ou notificações via webhook) e visualização gráfica (ex: dashboards em Streamlit ou Grafana).

























