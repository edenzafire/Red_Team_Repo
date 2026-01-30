# Relatório OSINT - Análise de Consistência de Usernames
**Rastreamento Cross-Platform e Evolução de Identificadores** 

**Aviso Legal:** Todos os usernames foram mascarados/ofuscados. Exemplo simulado baseado em padrões reais de comportamento digital.

## Resumo Executivo
- Total de plataformas identificadas com variações do username: **~58 serviços**
- Período de uso estimado: 2011 – presente
- Padrão principal: Combinação de nome "z***" + sobrenome "g********" / "d********"
- Observação chave: Evolução clara do username ao longo do tempo (de formal/completo para curto + número)
- Handles identificados: **6 variações principais**
- Padrão de nomenclatura: `[Nome][Iniciais][Dígitos]`
- Objetivo: Criar um grafo de conexões entre perfis pessoais, educacionais e profissionais para ampliar a superfície de ataque.

## Tabela de Correlação de Identidade
| Alias (Mascarado) | Plataforma Exemplo | Observação de Inteligência |
| :--- | :--- | :--- |
| `z***d********` | Dubsmash / Gerais | Handle padrão para serviços de entretenimento. |
| `z******_g***` | Twitter / X | Utilizado para identificação em redes sociais abertas. |
| `z******gd**` | Edmodo / Educação | Vinculação com ambiente acadêmico/estudantil. |
| `z****.d********_` | Instagram | Perfil com maior volume de metadados sociais. |
| `z***g*********` | James Delivery | Vinculação direta com dados de consumo (Pivoting Geográfico). |

## Análise de Padrão (Behavioral Analysis)
A persona demonstra baixa variabilidade na criação de nomes de usuário, o que permite o uso de técnicas de **Username Squatting** e buscas automatizadas (Sherlock/Maigret) com alta taxa de assertividade.

## Mapeamento MITRE ATT&CK
* **T1593.001:** Search Open Social Media Platforms.
* **T1589.003:** Gather Victim Identity Information: Usernames.

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

** As evidências você pode ver aqui ** https://github.com/edenzafire/Portfolio_pentest/tree/main/01_Osint/01_ClearWeb/evidence

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
