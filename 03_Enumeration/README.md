# 📂 Fase 03: Enumeration (Enumeração)

![Status: Concluído](https://img.shields.io/badge/Status-Conclu%C3%ADdo-success?style=for-the-badge)
![Nível: Sênior](https://img.shields.io/badge/N%C3%ADvel-Master-gold?style=for-the-badge)
![Conformidade: NIST & OWASP](https://img.shields.io/badge/Compliance-NIST%20%7C%20OWASP-blue?style=for-the-badge)

## 🎯 Objetivo da Fase
Nesta etapa, transformamos dados brutos em inteligência técnica acionável. O objetivo foi interagir ativamente com os serviços para identificar banners de versão, diretórios ocultos e configurações permissivas que servirão de vetores para as próximas fases de exploração.

---

## 🛡️ Nota sobre Discrição vs. Visibilidade (OPSEC)

> [!TIP]
> **Considerações de Evasão e Monitoramento:**
> Embora em cenários reais de Red Team sejam priorizadas técnicas de **Living off the Land (LotL)** e métodos de enumeração furtiva (stealth) para evitar detecção por EDRs e SIEMs, este laboratório optou deliberadamente pelo uso de ferramentas padrão da indústria como `nmap`, `gobuster` e `nikto`. 
>
> **Esta decisão estratégica visa:**
> 1. **Fomentar o Treinamento do Blue Team:** Gerar logs e telemetria suficientes para que as equipes de defesa possam validar suas regras de detecção e assinaturas de ataques conhecidos.
> 2. **Metodologia de Portfólio:** Documentar de forma clara e didática a identificação de vetores de ataque através de ferramentas consolidadas.
> 3. **Eficiência de Escopo:** Priorizar a cobertura total da superfície de ataque em ambiente controlado, simulando um teste de invasão (Pentest) focado em vulnerabilidades.

---

```mermaid
graph TD
    %% Definição de Estilos
    classDef attacker fill:#990000,stroke:#fff,stroke-width:2px,color:#fff;
    classDef target fill:#1e1e2e,stroke:#45475a,stroke-width:1px,color:#cdd6f4;
    classDef pivot fill:#d4a017,stroke:#fff,stroke-width:2px,color:#fff;
    classDef crown fill:#2e7d32,stroke:#fff,stroke-width:2px,color:#fff;

    %% Nós da Rede
    Atk([💀 debian12RED]) -->|Exploit: RCE| A1[Alvo 01: Apache/DVWA]
    
    subgraph LAN [Rede Interna de Exploração]
        A1 -->|Pivot / SSH Tunneling| A2[Alvo 02: Win 10]
        A1 -->|Lateral Movement| A3[Alvo 03: Meta2]
    end

    subgraph AD_ZONE [Segmento Active Directory]
        A2 -.->|Pivoting| A4[Alvo 04: TryHackMe]
        A4 ===>|Domain Admin Access| AD[Active Directory DS]
    end

    %% Aplicação de Estilos
    class Atk attacker;
    class A1,A4 pivot;
    class AD crown;
    class A2,A3 target;
```
## 🏗️ Estratégia de Rede & Superfície de Ataque

| Alvo | Papel no Lab | Vetor Crítico Identificado | Complexidade |
| :--- | :--- | :--- | :--- |
| **Alvo 01 (Apache)** | Foothold (Ponto de Apoio) | Injeção de Comandos (RCE) | Média |
| **Alvo 02 (Win 10)** | Lateral Movement Target | SMB Vulnerável / WinRM | Alta |
| **Alvo 03 (Meta2)** | Pivot / Data Exfiltration | Serviços Legados & Backdoors | Baixa |
| **Alvo 04 (TryHackme)** | Pivoting / Entry Point AD | Credential Dumping / Kerberoasting | Crítica |

---

## 📚 Frameworks e Metodologias de Referência

* **[PTES](http://www.pentest-standard.org/):** Padronização do fluxo de trabalho e camadas do modelo OSI.
* **[MITRE ATT&CK® (TA0007)](https://attack.mitre.org/tactics/TA0007/):** Técnicas de Discovery e reconhecimento interno.
* **[NIST SP 800-115](https://csrc.nist.gov/publications/detail/sp/800-115/final):** Integridade técnica e procedimentos de testes.
* **[OWASP WSTG](https://owasp.org/www-project-web-security-testing-guide/):** Guia de teste de segurança para aplicações Web.

---

## 🛠️ Toolstack (Arsenal Utilizado)

* **Network Discovery:** `nmap` (Service Detection & NSE Scripts).
* **Web Enumeration:** `gobuster`, `nikto`, `dirb`.
* **Windows/AD Recon:** `enum4linux-ng`, `smbclient`.
* **Banner Grabbing:** `netcat` & `curl`.

---

## 🛠️ Custom Tooling

* **AutoEnum (Bash):** Orquestração de ferramentas para varredura em massa.
* **BannerHunter (Python):** Extração de assinaturas e análise de risco preliminar.

> "A automação nesta fase visa reduzir a margem de erro humano e garantir a padronização na coleta de evidências."

---

## 📄 Relatórios Detalhados nesta Pasta

1.  [**01-Enumeration-Apache.md**](./01-Enumeration-Apache.md): Foco em Web App e exploração de RCE.
2.  [**02-Enumeration-Win10.md**](./02-Enumeration-Win10.md): Foco em protocolos de rede interna (SMB/WinRM).
3.  [**03-Enumeration-Metasploitable2.md**](./03-Enumeration-Metasploitable2.md): Foco em infraestrutura legada e backdoors.
4.  [**04-Enumeration-THM-AD.md**](./04-Enumeration-THM-AD.md): Foco em Pivoting e reconhecimento de Active Directory.

---

👉 **[Ver Mitigações no Repo de Blue Team](https://github.com/seu-link-aqui)**
