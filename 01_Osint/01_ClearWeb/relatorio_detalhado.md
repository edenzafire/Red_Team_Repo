# Relatório OSINT Mascarado para Portfólio Público
**Demonstração Técnica de Coleta, Organização e Análise Ética de Dados Vazados**  
**Data de Geração:** 20/12/2025  
**Autor:** Zafire Daniel 
**Objetivo:** Mostrar metodologia completa de OSINT passivo sem expor dados reais de terceiros  

**Aviso Legal**  
Todos os dados reais foram mascarados ou ofuscados. Este relatório utiliza informações fictícias simuladas a partir de vazamentos reais antigos, apenas para fins educacionais e demonstração de habilidades em cibersegurança.

## Resumo Executivo
- Total de leaks analisados → **10 fontes distintas**  
- Período dos vazamentos → 2018–2023  
- Email central (mascarado) → r***_1@h******.com  
- Nome completo (mascarado) → R****** R******** M********  
- Data de nascimento (mascarada) → **/**/1998  
- Cidades identificadas → C****** – PR (atual) e P**** A***** – RS (leak 2019)

## Tabela de Vazamentos (Dados Totalmente Mascarados)

| ID Leak (parcial) | Fonte                  | Email (mascarado)     | Username (exemplo mascarado) | Tipo de Hash / Observação                              | Ano Aproximado |
|-------------------|------------------------|-----------------------|------------------------------|--------------------------------------------------------|----------------|
| 1bc2...           | Twitter 2023           | r***_1@h******.com   | R******_R***                 | -                                                      | 2023           |
| 00f3...           | Deezer                 | r***_1@h******.com   | R****** R******** M*****     | Dados pessoais + data de nascimento                    | 2019–2020      |
| 9c41...           | Dubsmash               | r***_1@h******.com   | r***m********                | PBKDF2-SHA256 (15.000 rounds) – hash completo exposto  | 2018           |
| 7372...           | Edmodo                 | r***_1@h******.com   | R******R***                  | Custom salted hash (não padrão)                        | 2019           |
| 7dcf...           | Descomplica            | r***_1@h******.com   | -                            | Campo codificado (provável Base64)                     | 2018           |
| 28fb...           | Leak isolado           | r***_1@h******.com   | R***R*********               | Apenas username                                        | -              |
| 3c44...           | Site .inf.br           | r***_1@h******.com   | -                            | bcrypt ($2y$10$) – custo 10                            | 2020           |
| 2460...           | James Delivery         | r***_1@h******.com   | -                            | Coordenadas precisas + token JWT + push tokens Firebase| 2019           |
| bee9...           | Habibs                 | r***_1@h******.com   | R*** R********               | IP + Lat/Long precisão ~500m + Android device IDs     | 2019           |
| -                 | Canva / Toondoo        | r***_1@h******.com   | -                            | Mesmo hash SHA1 reutilizado em ambos os leaks         | 2019           |

## Perfis de Redes Sociais Identificados (Mascarados)
- Instagram Principal → @r***.m********_ (conta privada, ~582 seguidores)  
- Instagram Secundário → @r****.m********_ (conta privada, bio: “C****** :>”)  
- Facebook → facebook.com/r************ (perfil ativo desde 2011, mora em C******)

## Achados Técnicos Relevantes
1. **Reutilização extrema de credenciais**  
   → Mesmo email usado em mais de 15 serviços diferentes  
   → Senhas/hashes reutilizados em pelo menos 3 vazamentos distintos

2. **Exposição de geolocalização precisa**  
   → Coordenadas com precisão de ~500m (leak Habibs 2019)  
   → Segundo ponto geográfico em leak de delivery (área metropolitana)

3. **Exposição de identificadores de dispositivo**  
   → Facebook ASID completo  
   → Múltiplos push tokens Firebase (APA91b...)  
   → Token JWT válido na época  
   → IDs internos de apps mobile

4. **Usernames consistentes em dezenas de sites**  
   → Variações encontradas em ~58 plataformas (Spotify, GitLab, Threads, etc.)



## Avaliação de Risco (Simulada)

| Categoria              | Nível de Risco | Justificativa (exemplo genérico)                  |
|-----------------------|----------------|---------------------------------------------------|
| Identidade            | Alto           | Nome completo + data de nascimento + cidades      |
| Credenciais           | Alto           | Hashes crackeáveis + reutilização massiva         |
| Geolocalização        | Alto           | Coordenadas precisas em dois vazamentos           |
| Dispositivos/Tokens   | Alto           | Possibilidade de clonagem de sessão               |
| Perfil Digital        | Médio-Alto     | Doxing facilitado por usernames consistentes     |

## Metodologia Utilizada 
- Coleta passiva via fontes públicas e breaches conhecidos  
- Parsing automatizado com Python (pandas + regex)  
- Remoção de duplicatas e normalização de dados  
- Mascaramento total antes de qualquer exposição pública  
- Organização em Markdown + tabelas para relatórios  
- Integração com Maltego CE (transforms locais


## 🛠️ Ferramentas Utilizadas
Mapeamento realizado através de ferramentas líderes de mercado e automação própria:

* **Holehe:** Verificação de contas em serviços via mecanismos de recuperação de senha.
* **Have I Been Pwned (HIBP):** Consulta de histórico de brechas de segurança.
* **Maigret & Sherlock:** Rastreamento de consistência de identificadores (usernames) em centenas de plataformas.
* **Automação Própria:** Script Python utilizando a API do **BreachDirectory** para busca automatizada de hashes e fontes de vazamento.

> 📁 **Acesse meu script aqui:** https://github.com/edenzafire/Portfolio_pentest/blob/main/Scripts/scripts_osint/bd_lookup.py


## Inventário de Exposição (Breaches)
Abaixo, os principais pontos de exposição identificados através de correlação de e-mail e username:

| Fonte do Vazamento | Ano | Dado Exposto | Tipo de Hash / Proteção |
| :--- | :--- | :--- | :--- |
| **Deezer** | 2019 | Nome, Nascimento, Localização | Dados em Texto Plano |
| **James Delivery** | 2019 | Geolocalização, Tokens JWT, Firebase | - |
| **Dubsmash** | 2018 | Username, Hash de Senha | PBKDF2-SHA256 |
| **Site .inf.br** | 2020 | Username, Hash de Senha | bcrypt ($2y$10$) |
| **Habibs** | 2019 | IP, Lat/Long, Device IDs | Coordenadas precisas |

## Análise Profunda de Vetores

### 1.1. Correlação Geográfica e Rastreamento
A análise cruzada entre os vazamentos do **James Delivery** e **Habibs** permitiu a triangulação de coordenadas geográficas. Embora os dados sejam de 2019, o histórico estabelece um padrão de residência e consumo que pode ser explorado em ataques de engenharia social direcionada.

### 1.2. Análise de Criptografia (Hashes)
Foram identificados diferentes níveis de maturidade criptográfica nos serviços afetados:
* **SHA1 (Canva/Toondoo):** Extremamente vulnerável a ataques de colisão e *rainbow tables*.
* **bcrypt (Site .inf.br):** Implementação robusta (custo 10), demonstrando uma maior dificuldade de quebra via força bruta.
* **Reuso de Hash:** Identificou-se que o mesmo hash SHA1 foi encontrado em plataformas distintas, confirmando o **reuso de senhas** pelo usuário na época.


### 🌐 2.0 Habibs. Análise de Infraestrutura e Conectividade (Network Artifacts)
Durante o parsing dos vazamentos (Leaks de 2019), foi isolado um artefato de rede persistente:

* **Endereço IP Identificado:** `187.6.181.16`
* **ASN:** `AS27699` (Telefônica Brasil S.A / VIVO)
* **Origem do Dado:** Metadados de log de acesso vinculados ao vazamento Habibs.
* **Geolocalização Histórica:** Brasil, Regional Curitiba PR.

#### 🧠 Relevância para a Investigação:
A identificação deste IP permite realizar a técnica de **Pivotagem**. No contexto de um Pentest profissional, este dado não é apenas um número, mas um ponto de partida para:
1.  **Mapeamento de ASN:** Identificar se o alvo opera em redes domésticas ou se possui blocos de IP empresariais dedicados.
2.  **Passive DNS (pDNS):** Verificar se este IP já resolveu para algum domínio oficial ou subdomínio de infraestrutura (ex: `vpn.empresa.com.br`).
3.  **Análise de Histórico de Portas:** Consultar bases como Shodan/Censys para entender quais serviços estavam expostos nesta interface na data do vazamento.
## Conclusão e Avaliação de Risco
A exposição é classificada como **ALTA**. Apesar da antiguidade dos dados, a consistência de usernames (`r***.m********_`) permite a migração do ataque para plataformas modernas (Instagram/Threads/GitLab), onde o atacante pode tentar *Credential Stuffing* ou ataques de recuperação de conta.

## Recomendações de Segurança (Remediação)
1.  **Auditoria de E-mail de Recuperação:** Garantir que e-mails de 2011 não sejam o único método de recuperação de contas modernas.
2.  **MFA de Hardware/App:** Eliminar a dependência de senhas onde os hashes já foram vazados.
3.  **Higienização de Identidade:** Solicitação de deleção de dados baseada na LGPD/GDPR para os sites identificados.

