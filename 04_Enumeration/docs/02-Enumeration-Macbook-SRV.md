# Relatório Técnico: Enumeração Avançada de Host (Macbook-SRV)

**ID:** 04-ENUM-MACBOOK

**Operador:** Nikolay (Red Team)

**Data:** 15 de Maio de 2026

**Alvo:** 192.168.1.126 (Debian 12 / Macbook-SRV)

**Vetor de Acesso:** Pivoting via Sessão 1 (WIN10-LAB)

---

## 0x01. Sumário Executivo

Diferente de alvos propositalmente vulneráveis, o host **192.168.1.126** apresenta serviços atualizados (Debian Bookworm). No entanto, a fase de enumeração revelou **falhas críticas de configuração (Misconfigurations)** nos protocolos SMB e HTTP, além da exposição de nomes de usuários reais, o que viabiliza ataques de força bruta e exfiltração de dados em fases posteriores.

## 0x02. Mapeamento MITRE ATT&CK

|**Tática**|**Técnica**|**ID**|**Descrição**|
|---|---|---|---|
|**Discovery**|Account Discovery|[T1087.002](https://attack.mitre.org/techniques/T1087/002/)|Enumeração de usuários locais via SMB SID Lookup.|
|**Discovery**|Permission Groups Discovery|[T1069](https://attack.mitre.org/techniques/T1069/)|Identificação de compartilhamentos de rede sem autenticação.|
|**Reconnaissance**|Gather Victim Org Information|[T1592](https://attack.mitre.org/techniques/T1592/)|Fingerprinting de versões de software (Apache, OpenSSH, Samba).|

---

## 0x03. Timeline de Execução e Evidências

### 1. Varredura de Portas e Serviços

Identificação inicial da superfície de ataque exposta.

- **Portas Ativas:** 22 (SSH), 80 (HTTP), 445 (SMB).
    
- **Evidência:** 

![01Listando oque tem aberto.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/02MacbookApache/01Listando%20oque%20tem%20aberto.png)
    

### 2. Enumeração de Usuários (SMB SID Lookup)

Exploração de sessões nulas para coletar contas válidas no sistema.

- **Usuário Identificado:** `zafire` (RID 1000).
    
- **Domínio:** `MACBOOK-LAB`.
    
- **Análise:** O RID 1000 indica o usuário principal/administrador do sistema.
    
- **Evidência:** 

![02VarreduraSmb.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/02MacbookApache/02VarreduraSmb.png)

 etambém:

![06VersãoSmb.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/02MacbookApache/06Vers%C3%A3oSmb.png)
    

### 3. Fingerprinting de Versões (Software Identification)

Coleta de banners para análise de CVEs (Vulnerability Research).

- **SSH:** `OpenSSH 9.2p1 Debian-2+deb12u9` (Versão estável). [Evidência: 03VarreduraSSH.jpg]
    
- **HTTP:** `Apache 2.4.67 (Debian)` (Versão estável). [Evidência: 04VersãoApache.jpg]
    
- **Samba:** `Samba 4.17.12-Debian`. [Evidência: 05VersãoSamba.jpg]
    

### 4. Análise de Compartilhamentos (Shares)

Uso de `smbclient` para validar o acesso a pastas sem credenciais.

- **Compartilhamentos Visíveis:** `lab_share`, `print$`, `nobody`.
    
- **Status:** **Leitura anônima permitida** no compartilhamento de IPC e listagem de recursos.
    
- **Evidência:**
 ![09SmbClient.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/02MacbookApache/09SmbClient.png)

 e Também:

 ![08SmbNmap.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/02MacbookApache/08SmbNmap.png)
    

---

## 0x04. Matriz de Vetores de Ataque

|**Vetor**|**Descrição Técnica**|**Gravidade**|
|---|---|---|
|**Autenticação SSH**|Ataque de dicionário direcionado ao usuário `zafire`.|**ALTA**|
|**SMB Leakage**|Acesso ao conteúdo do `lab_share` via sessões nulas.|**MÉDIA**|
|**Web Fuzzing**|Exploração de diretórios como `/icons/` para encontrar arquivos indexados.|**BAIXA**|

---

## 0x05. Conclusão e Próximos Passos

A enumeração do host 192.168.1.126 foi concluída com sucesso. Embora o sistema esteja atualizado, a **má configuração do Samba** forneceu o nome de usuário necessário para um ataque de força bruta contra o serviço SSH.

**Recomendações para a Fase 05 (Vulnerability Research):**

1. Realizar ataque de força bruta via Metasploit (`auxiliary/scanner/ssh/ssh_login`) utilizando o usuário `zafire`.
    
2. Investigar o conteúdo do diretório `/lab_share` em busca de chaves privadas ou arquivos de configuração.
    

---

**Log de Operação Completo:** [relatorio_completo.txt](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/02MacbookApache/relatorio_completo.txt)
