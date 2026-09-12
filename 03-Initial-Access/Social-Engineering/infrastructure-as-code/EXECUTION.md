# 📖 Guia Prático de Execução - Infraestrutura como Código (IaC)

Este documento descreve o passo a passo detalhado para provisionar, gerenciar e destruir a infraestrutura do servidor de testes de Engenharia Social (**GoPhish**) na AWS usando **Terraform**. 

> **Aviso de Uso Ético:** Este ambiente destina-se exclusivamente a testes de conscientização, simulações de defesa e estudo em ambiente de laboratório controlado (*Purple Team*).

## 🛠️ 1. Entendendo a Estrutura dos Arquivos

Antes de executar os comandos, veja o papel de cada arquivo na pasta:

* **`main.tf`**: O arquivo principal. Ele instrui a AWS a criar os recursos físicos (a máquina virtual EC2, o IP fixo e as regras de firewall *Security Group*).
* **`variables.tf`**: O arquivo de configurações. Guarda variáveis como a região da AWS e o seu endereço de IP para limitar o acesso administrativo.
* **`outputs.tf`**: O arquivo de retorno. Quando a execução termina, ele exibe na tela o IP público gerado e as URLs de acesso ao painel do GoPhish.
* **`scripts/user_data.sh`**: O script de automação. Assim que a máquina virtual liga, este script instala o Docker e inicia o container do GoPhish automaticamente.

## 🚀 2. Passo a Passo de Execução

*Passo 1: Configurar suas Credenciais da AWS*

Antes de rodar o Terraform, certifique-se de que a AWS CLI está configurada no seu terminal com o usuário IAM correto:

```
aws configure

```
Insira sua AWS Access Key, Secret Key e a região us-east-1.

*Passo 2: Atualizar seu IP de Segurança*

Abra o arquivo variables.tf e certifique-se de definir o seu IP público na variável your_ip. Isso garante que as portas de gerenciamento (SSH e Painel Admin 3333) fiquem abertas apenas para a sua máquina.

Para descobrir seu IP atual, rode no terminal:

```
curl ifconfig.me

```
## Passo 3: Inicializar o Terraform

Execute o comando abaixo para baixar os conectores (providers) da AWS necessários para o projeto:

```
terraform init

```
## Passo 4: Simular a Criação (Planejamento)

Verifique o que o Terraform planeja criar sem alterar nada na AWS ainda:

```
terraform plan

```
*Dica: Analise a saída para garantir que tudo está de acordo com o esperado.*

## Passo 5: Criar a Infraestrutura (Deploy)

Execute o comando de aplicação para subir o servidor na nuvem:

```
terraform apply

```
*  Digite yes quando o terminal solicitar a confirmação.
*  O processo leva cerca de 1 a 2 minutos.

## Passo 6: Acessar a Aplicação

Ao finalizar, o terminal exibirá os dados definidos no outputs.tf:

*  1.  Aguarde cerca de 3 minutos para o script user_data.sh terminar a instalação do Docker na máquina.
*  2.  Acesse o painel administrativo pelo navegador via HTTPS na porta 3333 (exemplo: https://:3333).

## 🧹 3. Encerramento e Destruição dos Recursos

Após concluir os testes no laboratório, é fundamental desativar a infraestrutura para garantir a segurança do ambiente e evitar cobranças desnecessárias na conta AWS.

Execute o comando abaixo:

```
  terraform destroy

```

*  Digite yes para confirmar a exclusão.
*  Todos os recursos criados (EC2, IP fixo, Security Groups) serão removidos de forma limpa.





