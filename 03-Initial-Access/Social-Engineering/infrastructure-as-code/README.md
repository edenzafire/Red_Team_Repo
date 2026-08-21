# ☁️ Red Team Infrastructure Setup (AWS)

Documentação do provisionamento da infraestrutura na nuvem (AWS) para suportar a simulação de Acesso Inicial / Phishing.

## 🛠️ Arquitetura e Componentes

1. **AWS EC2 (Instance):** Servidor hospedando os serviços da campanha (ex: GoPhish / Nginx / C2 Redirector).
2. **AWS Security Groups:** Regras estritas de firewall (liberando apenas portas essenciais como 80, 443 e SSH restrito).
3. **Route 53 / Registrador de Domínio:** Configuração do domínio utilizado na simulação.
4. **Registros DNS:** Configuração de registros A, CNAME, SPF e DKIM para garantir entregabilidade de e-mails de teste.

---

## 📋 Passo a Passo de Configuração

### 1. Criação da Conta e IAM
* Setup da conta AWS com MFA habilitado.
* Criação de usuário IAM com permissões de princípio do menor privilégio para gerenciar os recursos do lab.

### 2. Provisionamento da Instância EC2
* **AMI:** Ubuntu Server / Debian.
* **Tipo:** `t2.micro` / `t3.micro` (ideal para laboratório e Free Tier).
* **Network:** Configuração de IP Público (Elastic IP) associado.

### 3. Regras de Firewall (Security Groups)
* **Inbound Rules:**
  * `TCP 22` (SSH) - Restrito ao IP do operador.
  * `TCP 80` (HTTP) - Aberto para verificação/redirect.
  * `TCP 443` (HTTPS) - Certificados SSL/TLS via Let's Encrypt.
