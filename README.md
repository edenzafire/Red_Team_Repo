<p align="center">
  <a href="https://github.com/edenzafire/Portfolio_pentest">
    <img src="images/capa.jpg" alt="Capa do Portfólio Pentest" style="border-radius:50px; border:3px solid red;" />
  </a>
</p>

# 🛡️ Pentest – Estudos, Metodologias e Projetos

Este diretório reúne materiais, estudos e projetos relacionados a **pentest** (testes de intrusão) com o objetivo de aprofundar conhecimentos em segurança ofensiva.

Aqui são organizadas subpastas que abrangem diferentes áreas da segurança — como **OSINT**, **Enumeration**, **Vulnerability Research**, e outras áreas relacionadas à segurança ofensiva.

O objetivo é manter um repositório claro, estruturado e evolutivo que reflita o desenvolvimento contínuo dos estudos.

## Esteprojeto está estruturado na seguinte ordem

## 🔎 1) OSINT – Open Source Intelligence

A etapa de OSINT consiste na coleta e análise de informações públicas disponíveis em fontes abertas.
Aqui são documentadas técnicas usadas para identificar dados sensíveis, pegadas digitais e possíveis vetores de ataque antes mesmo de qualquer interação direta com o alvo.

As práticas incluem:

Coleta de informações públicas

Footprinting de organizações e indivíduos

Análise de metadados

Mapeamento de superfícies expostas

Busca em redes sociais

Coleta em fontes abertas (DNS, WHOIS, motores de busca, leaks)

Identificação de riscos derivados de exposição pública

📁 Pasta do OSINT:

[🔎 OSINT](https://github.com/edenzafire/Portfolio_pentest/tree/main/OSINT)




## 🔎 2) Reconnaissance (Recon)

A etapa de Recon é essencial em qualquer avaliação de segurança.  
Aqui documento práticas de:

- Reconhecimento Passivo  
- Reconhecimento Ativo  
- Fingerprinting  
- Coleta de Metadados  
- Enumeração de Serviços  
- Coleta de Infraestrutura Exposta  
- Mapeamento de Superfície de Ataque  

📁 **Pasta do Recon:**  

[🕵️‍♂️ Recon](https://github.com/edenzafire/Portfolio_pentest/tree/main/Recon)


## 🧩 3) Enumeration (Enumeração)

A fase de Enumeração é onde transformamos as informações coletadas no Recon em dados mais profundos e estruturados sobre os serviços ativos, portas abertas, versões de softwares e possíveis vetores de ataque.
É uma etapa essencial para identificar pontos fracos exploráveis.

Nesta seção são documentadas práticas como:

Enumeração de serviços (HTTP, SMB, FTP, SSH, RPC, etc.)

Identificação de versões e banners

Descoberta de usuários, grupos e compartilhamentos

Varreduras aprofundadas com Nmap e NSE

Enumeração de diretórios e endpoints

Enumeração de vulnerabilidades preliminares

Coleta ativa para identificar superfícies de ataque internas

📁 Pasta de Enumeration:

[🧩 Enumeration](https://github.com/edenzafire/Portfolio_pentest/tree/main/Enumeration)


🟦 4) Vulnerability Research (Pesquisa de Vulnerabilidades)

A fase de Vulnerability Research é dedicada à identificação, análise e compreensão profunda das vulnerabilidades descobertas durante Recon e Enumeration.
Aqui são documentadas técnicas e métodos utilizados para investigar fraquezas em sistemas, aplicações e serviços, além de análises mais avançadas que envolvem exploração teórica.

As práticas incluem:

Identificação e validação de vulnerabilidades

Análise de CVEs e bancos de dados de segurança

Avaliação de impacto e severidade

Estudo de vetores de exploração conhecidos

Pesquisa manual e uso de scanners (Nmap NSE, Nikto, Nessus, OpenVAS, etc.)

Criação de notas técnicas sobre falhas detectadas

Entendimento profundo das causas e da possibilidade de exploração

📁 Pasta de Vulnerability Research:

[🟦 Vulnerability-Research](https://github.com/edenzafire/Portfolio_pentest/tree/main/Vulnerability-Research)
