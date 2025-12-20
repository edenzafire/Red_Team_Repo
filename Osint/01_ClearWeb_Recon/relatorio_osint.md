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

## Achados Técnicos Relevantes (Demonstração de Capacidade)
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

## Metodologia Utilizada (Mostre isso no portfólio!)
- Coleta passiva via fontes públicas e breaches conhecidos  
- Parsing automatizado com Python (pandas + regex)  
- Remoção de duplicatas e normalização de dados  
- Mascaramento total antes de qualquer exposição pública  
- Organização em Markdown + tabelas para relatórios  
- Integração opcional com Maltego CE (transforms locais)

