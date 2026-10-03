### 01-Planning — Plano de Coleta OSINT (Self-Assessment)

*  ID do Projeto: OSINT-SELF-2026-001 Versão: 3.0 
*  Status: Ativo
*  Analista: Éden Zafire 
*  Data de início: 03/10/2026
*  Revisão prevista: 

---

### 1. Objetivo
 Simular, contra o próprio ativo digital (identidade pessoal), o processo de reconhecimento que um adversário real conduziria antes de uma operação de initial access — e produzir um relatório de inteligência com achados acionáveis e plano de remediação.

 Resultado esperado: relatório (12-Intelligence-Report) que responda integralmente os PIRs abaixo, com níveis de confiança documentados e remediação priorizada.

---

### 2. Escopo

```
Item	Definição
Alvo	Identidade digital do próprio analista (nome, e-mail, usernames, telefone, imagens)
Ativos secundários	Domínios/serviços pessoais de propriedade do analista
Vetores out-of-scope	Ativos de terceiros, dados de familiares/colegas (tratados apenas como entidade relacional, sem coleta ativa)
Janela temporal	Últimos 10 anos de exposição
Modo	Passivo优先 → ativo apenas sobre ativos próprios

```
---

### 3. Limites e Considerações Legais (Legal & Ethical Charter)

*  Nenhuma interação autenticada em contas de terceiros.
*  Nenhuma compra/acesso a dados de data brokers com dados pessoais; uso apenas de índices públicos (HIBP, pastes indexados).
*  DarkWeb: somente observação de índices de busca públicos; registro de metadados, nunca download/repostagem.
*  Todo dado coletado será registrado com fonte, timestamp e hash (evidences/); dados sensíveis (senhas, tokens) são redigidos — registra-se apenas a existência.
*  PII de terceiros incidentais: descartar e registrar em log de descarte.

---


### 4. Priority Intelligence Requirements (PIRs)

Regra de ouro: toda coleta deve responder um PIR. Coleta sem PIR = lixo digital.

```
ID	PIR (pergunta de inteligência)	Fase(s) de coleta
PIR-01	Quais credenciais/contas associadas ao meu e-mail estão expostas em breaches ou pastes?	04, 09
PIR-02	Qual é a minha pegada de identidade única (usernames/avatars/assinaturas) e onde ela permite correlação entre plataformas?	02, 05, 06
PIR-03	Quais dados meus estão publicamente indexados que habilitariam spearphishing ou engenharia social crível (T1566)?	03, 06
PIR-04	Qual é a minha superfície técnica exposta (domínios, subdomínios, serviços, e-mails em certificados, metadados de documentos)?	03, 04
PIR-05	Meu telefone está associado a contas públicas, anúncios ou vazamentos que habilitem smishing/voicemail recon?	07
PIR-06	A geolocalização inferível de minhas atividades (fotos, posts, check-ins) revela padrões de rotina exploráveis?	08
PIR-07	Existe exposição em canais não-indexados (fóruns, darkweb, marketplaces) associada à minha identidade?	DarkWeb

```
---

### 5. Collection Plan (matriz PIR → pasta → método)

```
Fase	Pasta	Ferramentas/métodos	Responde a	Prioridade
1. Passiva	04-E-mail	HIBP, Dehashed (índice), grep de pastes, have-i-been pwned API	PIR-01	Alta
1. Passiva	05-Username	WhatsMyName, Sherlock, namechk	PIR-02	Alta
1. Passiva	02-Identity	Clustering de usernames/avatars (hash de imagem, reverse search)	PIR-02	Alta
1. Passiva	06-Social-Media	Google dorks site:, Wayback, LinkedIn/Instagram público	PIR-02, PIR-03	Alta
1. Passiva	03-Public-Records	Registros públicos, WHOIS histórico, business registries	PIR-03, PIR-04	Média
2. Ativa (próprios ativos)	04/E-mail	CT logs (crt.sh), MX/SPF/DMARC/DKIM dos próprios domínios	PIR-04	Média
2. Ativa	07-Phone	Enumeração de portabilidade, lookup público, existence-probing em apps	PIR-05	Média
3. Geoespacial	08-Geo	EXIF de fotos públicas, análise de timeline de posts	PIR-06	Média
4. Não-indexado	DarkWeb	índices de busca públicos, monitoramento de dumps	PIR-07	Baixa
5. Correlação	10	Maltego/grafo, pivots e-mail→user→conta→dado exposto	Todos	—

```

### 6. Modelo de Adversário (Threat Model)

```
Perfil	Capacidade	O que interessa a ele
Atacante oportunista	Baixo	Credenciais vazadas → credential stuffing (T1110.004)
Phisher direcionado	Médio	Dados de PIR-03/05/06 → spearphishing crível (T1566, T1598)
APT/stalker avançado	Alto	Correlação completa de identidade, padrão de rotina, superfície técnica

```

### 7. Validação e Confiança

*  Sistema de confiança: Admiralty Code (confiabilidade da fonte A–F; credibilidade do dado 1–6) — documentado em 11-Validation-Confidence.
* Nenhum achado entra no relatório final sem ≥1 evidência bruta arquivada em evidences/ com hash SHA-256 e timestamp.

### 8. Critérios de Sucesso (Definition of Done)

1. Todos os PIRs respondidos ou explicitamente marcados como "não determinável" (com justificativa).
2. Cada achado mapeado a técnica MITRE ATT&CK PRE e vetor de initial access correspondente.
3. Relatório final com: executive summary, matriz de risco, plano de remediação priorizado (CIS v8 + hábitos operacionais).
4. Repo limpo: zero credenciais reais, zero PII de terceiros, evidências redigidas e hashadas.


