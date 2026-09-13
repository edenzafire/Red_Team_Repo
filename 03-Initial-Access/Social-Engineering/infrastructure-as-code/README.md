# ☁️ Red Team Infrastructure as Code (IaC) - AWS & GoPhish

Este repositório contém a documentação e os scripts de **Infraestrutura como Código (IaC)** para o provisionamento automatizado de um ambiente de simulação de Engenharia Social / Acesso Inicial (Red Team) na AWS. O projeto é focado em testes éticos, conscientização e estudos ofensivos em ambiente de **Purple Team**.

## 🛡️ 1. Hardening e Segurança da Conta (Cloud Baseline)

*   Antes da implantação da infraestrutura, a conta AWS passou por um processo de hardening alinhado às boas práticas do CIS AWS Foundations Benchmark:

*  MFA Obrigatório: Autenticação de múltiplos fatores ativada na conta Raiz (Root) e no usuário operador.

* Princípio do Menor Privilégio: Operação realizada exclusivamente via usuário IAM dedicado (edenzafire-Lab), sem uso de chaves ativas na conta Root.

*  FinOps Guardrails: Configuração de alarme AWS Budget Zero-Spend para notificação imediata de qualquer variação de custo.

## 🛠️ 2. Arquitetura e Recursos Provisionados

* O provisionamento é 100% automatizado via Terraform e Docker:

* Instância EC2 (t2.micro): Servidor Ubuntu rodando o GoPhish via Docker Compose de forma automatizada via user_data.sh.

* Elastic IP (EIP): Endereço IP público estático associado à máquina para manter a persistência de acesso.

**AWS Security Group (Firewall Restrito):**

* TCP 22 (SSH): Restrito estritamente ao IP público do operador.

* TCP 3333 (GoPhish Admin Console): Restrito estritamente ao IP público do operador.

* TCP 80 / 443 (HTTP/HTTPS): Abertos para a entrega da página de teste (Landing Page).

## 📁 3. Estrutura de Arquivos

```
infrastructure-as-code/
├── main.tf          # Definição dos recursos (EC2, EIP, Security Group, Keys)
├── variables.tf     # Declaração de variáveis (Região, IP do operador, ambiente)
├── outputs.tf       # Exibição do IP público e URLs de acesso ao final do deploy
├── README.md        # Documentação principal do módulo
├── EXECUTION.md     # Guia passo a passo detalhado para execução e destruição do lab
└── scripts/
    └── user_data.sh # Script Bash de automação (Instalação do Docker e GoPhish)
```

## 📋 4. Pré-requisitos e Execução Rápida

1. Possuir a AWS CLI instalada e autenticada (aws configure).

2. Possuir o Terraform (v1.0+) instalado localmente.

3. Atualizar o seu IP público no arquivo variables.tf.

** Comandos Principais:**

```
# Inicializa os conectores do Terraform
terraform init

# Valida o plano de execução
terraform plan

# Aplica e cria a infraestrutura na AWS
terraform apply

# Destrói todos os recursos criados (Para evitar custos pós-teste)
terraform destroy

```

>📌 Para instruções detalhadas de como executar, validar credenciais e acessar o painel administrativo, consulte o arquivo EXECUTION.md.

## ⚠️ Isenção de Responsabilidade (Legal Disclaimer)
Todo o conteúdo e código deste repositório foram criados estritamente para fins educacionais, construção de portfólio e testes de segurança autorizados em ambientes controlados. O uso destas ferramentas contra alvos sem autorização prévia por escrito é ilegal.
