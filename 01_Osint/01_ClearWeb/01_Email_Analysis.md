# Relatório OSINT - Análise de E-mail (Mascarado)
**Demonstração Técnica de Coleta e Análise de Breaches**
**Data:** 2025  
**Autor:** Zafire Daniel  
**Objetivo:** Mostrar metodologia de OSINT passivo focada em e-mail como pivô central, sem expor dados reais.

**Aviso Legal:** Todos os dados foram totalmente mascarados ou ofuscados para fins educacionais e portfólio público.

## Resumo Executivo
- E-mail pivô (mascarado): z*****_1@g******l.com
- Total de breaches identificados: **10 fontes distintas**
- Período: 2018–2023
- Principais riscos: Reutilização extrema de credenciais e hashes crackeáveis

## Tabela de Vazamentos Encontrados
| ID Leak (parcial) | Fonte              | E-mail (mascarado)      | Username (exemplo)     | Tipo de Hash / Observação                  | Ano     |
|-------------------|--------------------|--------------------------|-------------------------|--------------------------------------------|---------|
| 1bc2...           | Twitter 2023       | z*****_1@g******l.com   | z******_d***            | -                                          | 2023    |
| 00f3...           | Deezer             | z*****_1@g******l.com   | z****** g******** M*****| Dados pessoais + nascimento                | 2019–20 |
| 9c41...           | Dubsmash           | z*****_1@g******l.com   | r***m********           | PBKDF2-SHA256 (15.000 rounds)              | 2018    |
| 7372...           | Edmodo             | z*****_1@g******l.com   | z******d***             | Custom salted hash                         | 2019    |
| 7dcf...           | Descomplica        | z*****_1@g******l.com   | -                       | Campo codificado (provável Base64)         | 2018    |
| 28fb...           | Leak isolado       | z*****_1@g******l.com   | z***d*********          | Apenas username                            | -       |
| 3c44...           | Site .inf.br       | z*****_1@g******l.com   | -                       | bcrypt ($2y$10$) – custo 10                 | 2020    |
| 2460...           | James Delivery     | z*****_1@g******l.com   | -                       | Coordenadas + token JWT + Firebase tokens  | 2019    |
| bee9...           | Habibs             | z*****_1@g******l.com   | z*** d********          | IP + Lat/Long + Device IDs                 | 2019    |
| -                 | Canva / Toondoo    | z*****_1@g******l.com   | -                       | Mesmo hash SHA1 reutilizado                | 2019    |


## Análise de Pivoting (Data Correlation)
A partir do identificador de e-mail, foi possível realizar o *pivoting* para os seguintes módulos:
* **Módulo 02:** Descoberta de handles e aliases consistentes.
* **Módulo 04:** Extração de metadados geográficos e IPs associados a logins de apps.

## Achados Principais
- Mesmo e-mail registrado em **mais de 15 serviços diferentes**
- Reutilização confirmada de hashes (ex: mesmo SHA1 em Canva e Toondoo)
- Presença de hashes com diferentes níveis de proteção (de SHA1 vulnerável a bcrypt robusto)

## Ferramentas Utilizadas
- **Holehe** – Verificação de registros via recuperação de senha
- **Have I Been Pwned (HIBP)** – Consulta de breaches
- **BreachDirectory API** – Busca automatizada (script próprio)
- **Script Python**: [bd_lookup.py](https://github.com/edenzafire/Portfolio_pentest/blob/main/Scripts/scripts_osint/)

## Avaliação de Risco
| Categoria     | Nível   | Justificativa                          |
|---------------|---------|----------------------------------------|
| Credenciais   | Alto    | Reutilização massiva + hashes expostos |
| Identidade    | Alto    | Nome, nascimento e cidades vazados     |

## Conclusão
A análise do e-mail demonstra alto potencial de comprometimento via credential stuffing e engenharia social, mesmo com dados antigos.

**Próximos pivôs:** Usernames consistentes e artefatos geográficos (ver módulos relacionados).
