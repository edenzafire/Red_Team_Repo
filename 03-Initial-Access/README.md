# 🎯 Fase 03: Acesso Inicial (Initial Access)

> **Projeto:** Self Hacking & Red Team Lab  
> **Status:** Em Andamento (Ambiente Controlado)  
> **Fase Anterior:** [01_OSINT](../01_osint) & 02_Recon  

---

## 📌 Visão Geral

Esta é a **terceira etapa** do projeto de *Self Hacking*, focada em simular o ganho de acesso inicial a um ambiente corporativo/pessoal controlado. 

O objetivo principal desta fase é testar a eficácia dos vetores de entrada humana e validar se as informações levantadas nas fases anteriores são suficientes para contornar barreiras iniciais de segurança.

---

## 🧬 Metodologia e Mapeamento MITRE ATT&CK®

Nesta etapa, utilizamos os dados coletados e mapeados durante a **Fase 01 (OSINT)** para construir cenários realistas e hiper-direcionados. Toda a simulação segue os padrões da matriz [MITRE ATT&CK®](https://attack.mitre.org/).

* **Tática:** [Initial Access (TA0001)](https://attack.mitre.org/tactics/TA0001/)
* **Técnica:** [Phishing (T1566)](https://attack.mitre.org/techniques/T1566/)
  * **Sub-técnica:** [Spearphishing Link (T1566.002)](https://attack.mitre.org/techniques/T1566/002/)
  * **Sub-técnica:** [Spearphishing Attachment (T1566.001)](https://attack.mitre.org/techniques/T1566/001/)

### 📧 Spear Phishing & Engenharia Social
* **Vetor:** Campanha de Spear Phishing (Engenharia Social direcionada).
* **Mecanismo:** Contextualização da mensagem utilizando e-mails, nomes de projetos internos e tecnologias identificadas na etapa de inteligência.
* **Objetivo:** Involucrar o alvo em uma ação simulada (clique em link/execução de artefato educativo) para validar o comprometimento da primeira ponta da rede.

---

## 📂 Estrutura do Diretório

```text
├── social_engineering/
│   ├── templates/          # Templates de e-mails/páginas utilizadas nos testes
│   └── docs/               # Documentação dos cenários simulados
└── README.md               # Este arquivo de documentação
```

# ⚠️ Disclaimer e Termo de Isenção de Responsabilidade

**AVISO IMPORTANTE:**

Este repositório e seus arquivos contêm materiais desenvolvidos puramente para fins educacionais e de pesquisa em biossegurança cibernética.

* **Ambiente Controlado:** Todas as simulações, vetores e testes foram executados estritamente contra infraestrutura própria e autorizada, em ambiente de laboratório isolado (self-hacking).
* **Uso Não Autorizado:** O autor não se responsabiliza pelo uso indevido, malicioso ou ilegal das informações, técnicas ou diretórios contidos neste projeto. O uso de técnicas de engenharia social contra alvos não autorizados constitui crime.
