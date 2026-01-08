# Relatório OSINT - Análise de Consistência de Usernames
**Rastreamento Cross-Platform e Evolução de Identificadores**

**Data:** 08/01/2026  
**Autor:** Zafire Daniel  

**Aviso Legal:** Todos os usernames foram mascarados/ofuscados. Exemplo simulado baseado em padrões reais de comportamento digital.

## Resumo Executivo
- Total de plataformas identificadas com variações do username: **~58 serviços**
- Período de uso estimado: 2011 – presente
- Padrão principal: Combinação de nome "R***" + sobrenome "R********" / "M********"
- Observação chave: Evolução clara do username ao longo do tempo (de formal/completo para curto + número)

## Tabela de Variações de Usernames Encontradas
| Username Mascarado       | Padrão Observado                  | Estimativa de Antiguidade | Exemplos de Plataformas (genéricos)          | Quantidade Aprox. de Hits |
|---------------------------|-----------------------------------|---------------------------|---------------------------------------------|---------------------------|
| R*** R. M********         | Nome completo abreviado           | Mais antigo (2011+)       | Redes sociais antigas, fóruns, e-mail       | Alto                      |
| R*** R********            | Nome + Sobrenome completo         | Médio (2015–2018)         | Streaming, gaming, serviços brasileiros      | Médio-Alto                |
| R******RM29               | Nome + Iniciais + Número (idade?)  | Médio                     | Apps mobile, delivery, educação online      | Médio                     |
| R******_R***              | Nome + Underscore + Apelido       | Médio                     | Instagram, Threads, GitHub                  | Alto                      |
| R***R********4            | Apelido + Sobrenome + Número      | Recente (2019+)           | Plataformas modernas, redes sociais         | Alto                      |
| r***************          | Tudo minúsculo, juntinho          | Recente                   | Dev platforms, Discord, serviços técnicos   | Médio                     |

## Achados Técnicos Relevantes
- **Consistência extrema**: Mesmos padrões reutilizados em dezenas de sites de categorias diferentes (streaming de música, delivery, educação, redes sociais, dev platforms).
- **Evolução temporal clara**: Usernames mais antigos tendem a ser mais formais e completos; os recentes são encurtados com números para contornar disponibilidade.
- **Facilitador de doxing**: Qualquer variação permite pivotar para as outras via ferramentas como Maigret/Sherlock.
- **Risco atual**: Mesmo usernames "velhos" ainda levam a perfis ativos em plataformas modernas (Instagram, Threads, GitLab etc.).

## Ferramentas Utilizadas
- **Maigret** – Busca massiva em centenas de sites simultaneamente
- **Sherlock** – Verificação detalhada e persistente de usernames
- Correlação manual com dados de breaches (e-mail como pivô inicial)
- Exportação e análise de resultados em JSON/CSV

## Avaliação de Risco
- **Nível: Alto**
- Justificativa: Um único username (mesmo antigo) permite mapear todo o footprint digital histórico e atual, facilitando:
  - Doxing completo
  - Ataques de recuperação de conta
  - Credential stuffing em serviços onde o username é público

## Recomendações de Segurança
- Variar usernames por categoria de serviço (ex: um para gaming, outro para profissional, outro para redes sociais)
- Evitar inclusão de datas de nascimento, idades ou padrões previsíveis
- Monitorar exposição com ferramentas como Have I Been Pwned e Maigret periodicamente

## Conclusão
A análise de usernames demonstra como identificadores aparentemente "inofensivos" se tornam o elo mais fraco na privacidade digital. Um padrão consistente ao longo de 15 anos permite reconstruir toda a pegada digital do indivíduo – lição valiosa para usuários e defensores.
