# Relatório OSINT - Footprint em Redes Sociais
**Perfis Públicos e Privados Identificados**

## Perfis Encontrados (Mascarados)
- **Instagram Principal**: @z***.m********_ (privada, ~582 seguidores)
- **Instagram Secundário**: @z****.m********_ (privada, bio: “C****** :>”)
- **Facebook**: facebook.com/z************ (ativo desde 2011, localização mascarada: C****** – PR)
- **X/Twitter**: @Z******** (Nome exibido: R****** M********
User ID numérico: 182***************** (típico de conta nova, criada em agosto de 2024 – IDs longos assim são pós-2016).
Seguidores/Seguindo: 0 seguidores, atividade zero.
Avatar: Foto de homem de barba jovem (cabelo escuro longo, camisa preta e capus preto, fundo tecnologico /ambiente interno, corporativo)
- **Pinterest**: https://www.pinterest.com/z***e****g********el/_saved(mostra se muito ativo compartilhando gostos por artigos de casa, e beleza)

## Resumo Executivo
A análise de redes sociais permitiu a reconstrução da linha do tempo da persona, identificando transições geográficas e vínculos institucionais.

## Perfis Identificados
* **Rede Social A (Instagram):** 2 perfis (Principal/Secundário), confirmando transição de cidade (P*** A****** -> C*******).
* **Rede Social B (Facebook):** Perfil ativo desde 2011, revelando histórico escolar (Escola Y**** P*******).
* **Rede Social C (TikTok):** Presença confirmada via handle `r***r*********`.

## Inteligência Coletada (Vetores de Engenharia Social)
* **Background:** Histórico educacional identificado permite ataques de *Pretexting* fingindo ser ex-alunos ou administração escolar.
* **Timeline:** Atividade digital consistente entre 2018 e 2023.
* **Interesses:** Mapeamento de serviços de delivery e streaming para campanhas de *Smishing* segmentadas.
* **Pinterest: ** Demonstra um enorme interesse em violão, e arte, ideal para campanhas de *phishing*, o qual será na fase 04.

## Conclusão de Risco
A exposição de vínculos escolares e interesses pessoais permite a criação de iscas de phishing com **taxa de conversão estimada em >70%** devido ao alto nível de personalização.

## Observações
- Consistência de username com padrões encontrados em breaches
- Contas antigas ainda ativas, indicando footprint digital persistente
- Informações públicas limitadas devido a configurações de privacidade

## Ferramentas
- Busca manual + correlação com usernames de breaches
- Integração com resultados de Maigret/Sherlock
- **Apifi** - Scraping e footprinting de preferências
- Scriprs manuais em py

* 🔗 [**Scripts para a pasta de evidências (ScriptsOsint)**](https://github.com/edenzafire/Red_Team_Repo/tree/main/Scripts/scripts_osint )
* 🔗 [**As evidências você pode ver aqui **] (https://github.com/edenzafire/Red_Team_Repo/tree/main/01_Osint/01_ClearWeb/evidence ) 
## Risco

Médio-Alto → Facilita engenharia social e doxing quando combinado com dados vazados.
