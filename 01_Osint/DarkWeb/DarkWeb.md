# 🕶️ Dark Web Intelligence Report: Brazil-Targeted Breach Analysis

[![GitHub](https://img.shields.io/badge/GitHub-Repositorio-blue?logo=github)](https://github.com/edenzafire/Portfolio_pentest)
![Status: Research_Project](https://img.shields.io/badge/Status-Research_Project-brightgreen?style=for-the-badge)
![Target: .BR_Domains](https://img.shields.io/badge/Target-.BR_Domains-yellow?style=for-the-badge)

**Autor:** Zafire Daniel  
**Data:** 21 de Dezembro de 2025  
**Classificação:** TLP:WHITE (Relatório Público)  
**Versão:** 1.2
  

> **⚠️ Disclaimer:** Este relatório demonstra uma abordagem ética de OSINT na Dark Web. Todos os dados foram coletados de fontes públicas, anonimizados via regex e processados em ambiente isolado. Os resultados aqui expostos são simulados para fins de demonstração de conformidade com a LGPD e ética hacker.



## 🎯 1. Objetivos da Operação
O foco desta investigação foi realizar o **Threat Landscape Mapping** (Mapeamento do Cenário de Ameaças) voltado ao ecossistema digital brasileiro, visando:
* Identificar indicadores de exposição de domínios `.gov.br` e `.com.br`.
* Extrair e normalizar **Indicadores de Comprometimento (IOCs)**.
* Validar a eficácia de scripts customizados em ambientes de alto anonimato (Whonix).


## 🛠️ 2. Metodologia e Stack Técnico

### Camada de Ocultação (OpSec)
- **Plataforma:** Whonix 17+ configurado em VirtualBox, garantindo anonimato total através de isolamento de rede e roteamento Tor.
- **Configuração Detalhada do Ambiente Whonix/Tor:**  
  📄 [02_torConf.md - Guia completo de configuração e hardening do Whonix](https://github.com/edenzafire/Portfolio_pentest/blob/main/Osint/02_DarkWeb_Recon/02_torConf.md)


### Engenharia de Coleta (Automated Discovery)
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

## 📊 3. Technical Intelligence Findings (IOC Extraction)

Abaixo, os dados consolidados após o processamento de **25 fontes onion** (Ahmia, Torch, Fóruns Underground).

### Resumo de Exposições Identificadas (Mascarado)

Páginas Analisadas: Aproximadamente 25 (crawling até profundidade 2, com otimização para evitar sobrecarga).
Menções Relevantes: 5 páginas com potenciais exposições.
IOCs Extraídos (Mascarados):

Emails: 12 (ex: us****@ex****.com.br, ad***@go****.br, fi****@ba****.com.br, cl****@em****.gov.br, se****@se****.com, jo****@pr****.br, ma****@co****.com.br, re****@fi****.gov.br, ti****@in****.br, va****@co****.com, wi****@te****.br, zo****@su****.com.br).

CPFs: 8 (ex: ***.***.***-**, ***.***.***-**, ***.***.***-**, ***.***.***-**, ***.***.***-**, ***.***.***-**, ***.***.***-**, ***.***.***-**).

Combos de Credenciais: 6 (ex: us****@ex****.com.br:senha1234, ad***@go****.br:acesso2025, fi****@ba****.com.br:passbr, cl****@em****.gov.br:govaccess, se****@se****.com:secure123, jo****@pr****.br:prbr2024).




| Categoria | Volume | Amostra Identificada (Exemplo) |
| :--- | :---: | :--- |
| **E-mails (.br)** | 12 | `cl****@em****.gov.br` |
| **Documentos (CPF)** | 08 | `***.***.***-**` |
| **Combo Lists** | 06 | `ad***@go****.br:acesso2025` |
| **Hashes/Leaks** | 10 | `[HASH_MASCARADO]`


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

## 🧠 4. Análise Tática e Recomendações
Padrões Observados
Credential Stuffing: Alta incidência de reaproveitamento de senhas em setores financeiros e governamentais.

**Pivoting Risk:**  E-mails expostos em fóruns técnicos servem como ponto de partida para ataques de Spear Phishing dir ecionados.

## Plano de Mitigação ##   (Strategic Insights)
**Para Organizações:** Implementar monitoramento ativo de Dark Web integrado ao SIEM e políticas de troca de senhas baseadas em risco.

Para Analistas: Expansão para monitoramento de protocolos I2P e integração de webhooks para alertas em tempo real.

## 🔗 Referências e Ferramentas
[OSINT Framework:]  osintframework.com

[MITRE ATT&CK]: T1597 - Search Closed Sources

[Whonix Project]: whonix.org

## Status Final:

 ✅ Investigação concluída sem incidentes de OPSEC.

## Próxima Etapa:

 Integração dos achados na Fase 04 - Social Engineering.











