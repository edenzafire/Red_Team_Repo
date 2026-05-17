### Passo a Passo da Enumeração de Elite (Alvo: 192.168.1.145)

Como você já está no console do MSF e com a rota configurada, execute estes comandos para extrair os detalhes de cada serviço:

#### 1. Versão do FTP (Porta 21)

O Metasploitable 2 é famoso por rodar o `vsftpd 2.3.4`, que possui um backdoor de fábrica.

Bash

```
use auxiliary/scanner/ftp/ftp_version
set RHOSTS 192.168.1.145
run
```

#### 2. Versão do SSH (Porta 22)

Útil para verificar se aceita autenticação por senha ou se tem chaves fracas.

Bash

```
use auxiliary/scanner/ssh/ssh_version
set RHOSTS 192.168.1.145
run
```

#### 3. Versão do SAMBA (Portas 139/445)

O Samba no Metasploitable 2 costuma ser vulnerável ao clássico `usermap_script` (RCE instantâneo como Root).

Bash

```
use auxiliary/scanner/smb/smb_version
set RHOSTS 192.168.1.145
run
```

#### 4. Enumeração de RPC (Porta 111)

Isso revela serviços NFS (pastas compartilhadas) que podem estar sem senha.

Bash

```
use auxiliary/scanner/nfs/nfs_stat
set RHOSTS 192.168.1.145
run
```

### 1. Enumeração de Banner e Versão (Geral)

Você já rodou o portscan, agora vamos pegar os detalhes:

Bash

```
use auxiliary/scanner/http/http_version
set RHOSTS 192.168.1.145
run

use auxiliary/scanner/ftp/ftp_version
set RHOSTS 192.168.1.145
run

use auxiliary/scanner/smb/smb_version
set RHOSTS 192.168.1.145
run
```

### 2. Enumeração de Usuários (SMTP e SMB)

O Metasploitable permite descobrir usuários válidos no sistema, o que é ótimo para ataques de força bruta depois.

Bash

```
# Verificar usuários via SMTP (Porta 25)
use auxiliary/scanner/smtp/smtp_enum
set RHOSTS 192.168.1.145
run

# Verificar compartilhamentos SMB sem senha
use auxiliary/scanner/smb/smb_enumshares
set RHOSTS 192.168.1.145
run
```

### 3. Enumeração de Banco de Dados (MySQL - Porta 3306)

Vamos ver se o MySQL permite conexão root sem senha (muito comum no Metasploitable).

Bash

```
use auxiliary/scanner/mysql/mysql_version
set RHOSTS 192.168.1.145
run

use auxiliary/scanner/mysql/mysql_login
set RHOSTS 192.168.1.145
set USERNAME root
set PASS_FILE /dev/null
run
```
##################

### Passo 1: Colocar a sessão em repouso (Background)

Digite o comando abaixo para liberar o terminal para novos comandos:

Bash

```
meterpreter > background
```

_Isso vai te devolver para o prompt `msf6 >` ou `msf exploit(...) >`._

### Passo 2: O comando de "Raio-X" (Versões dos Serviços)

Agora que você está no console principal, vamos mandar o Metasploit identificar o que cada porta do Metasploitable (192.168.1.145) está rodando.

**Copie e cole estes comandos (um por vez):**

1. **Para o FTP (Porta 21):**
    
    Bash
    
    ```
    use auxiliary/scanner/ftp/ftp_version
    set RHOSTS 192.168.1.145
    run
    ```
    
2. **Para o Samba/SMB (Portas 139/445):**
    
    Bash
    
    ```
    use auxiliary/scanner/smb/smb_version
    set RHOSTS 192.168.1.145
    run
    ```
    
3. **Para o SSH (Porta 22):**
    
    Bash
    
    ```
    use auxiliary/scanner/ssh/ssh_version
    set RHOSTS 192.168.1.145
    run
    ```
    

---

### Por que estamos fazendo isso?

A **Enumeração** é como ler o manual de uma fechadura antes de tentar abrir.

- Se o FTP responder `vsftpd 2.3.4`, você achou uma porta dos fundos.
    
- Se o Samba responder `Samba 3.0.20`, você tem as chaves da casa.

### 1. Enumeração de HTTP (Porta 80)

O Metasploitable tem um servidor web cheio de pastas ocultas e scripts vulneráveis. Vamos descobrir o que tem lá.

Bash

```
use auxiliary/scanner/http/dir_scanner
set RHOSTS 192.168.1.145
run
```

- **O que observar:** Veja se ele encontra diretórios como `/phpMyAdmin/`, `/twiki/` ou `/dav/`.
    

### 2. Enumeração de MySQL (Porta 3306)

Bancos de dados mal configurados são ótimos para extrair informações sensíveis.

Bash

```
use auxiliary/scanner/mysql/mysql_version
set RHOSTS 192.168.1.145
run
```

### 3. Enumeração de Java RMI (Porta 1099)

Essa porta é um "clássico" do Metasploitable 2. Quase sempre permite a execução de comandos remotos.

Bash

```
use auxiliary/scanner/misc/java_rmi_server
set RHOSTS 192.168.1.145
run
```

---
