
### 1. Enumeração Detalhada do Apache (Porta 80)

Vamos ver se esse Apache tem módulos específicos ou diretórios que não deveriam estar lá.

Bash

```
# Identificar o banner detalhado e módulos
use auxiliary/scanner/http/http_version
set RHOSTS 192.168.1.126
run

# Buscar por arquivos e pastas (Brute force de diretórios)
use auxiliary/scanner/http/dir_scanner
set RHOSTS 192.168.1.126
run
```

_Dica: Se ele encontrar algo como `/uploads/`, `/backup/` ou `/.git/`, temos um problemão de segurança para o dono do Mac._

### 2. Enumeração de SMB (Porta 445)

O SMB em Macs (via Samba ou nativo) costuma compartilhar pastas. Vamos tentar listar o que ele tem "aberto".

Bash

```
# Tentar listar compartilhamentos (shares) sem senha
use auxiliary/scanner/smb/smb_enumshares
set RHOSTS 192.168.1.126
run

# Tentar descobrir usuários do sistema via SMB
use auxiliary/scanner/smb/smb_lookupsid
set RHOSTS 192.168.1.126
run
```

### 3. Enumeração de SSH (Porta 22)

Só para confirmar se ele aceita autenticação por senha ou apenas chave.

Bash

```
use auxiliary/scanner/ssh/ssh_version
set RHOSTS 192.168.1.126
run
```

1. Versão Exata do Apache (Porta 80)
Isso vai nos dizer se o Apache tem alguma falha de Path Traversal ou se há vulnerabilidades nos módulos carregados.

Bash
use auxiliary/scanner/http/http_version
set RHOSTS 192.168.1.126
run
2. Versão Detalhada do Samba/SMB (Porta 445)
Como você já descobriu o usuário zafire, saber a versão do Samba ajuda a ver se há falhas de Remote Code Execution (RCE) recentes ou problemas de autenticação.

Bash
use auxiliary/scanner/smb/smb_version
set RHOSTS 192.168.1.126
run
3. Detecção de SO (OS Discovery)
Vamos pedir para o Metasploit tentar adivinhar a versão exata do Kernel através do comportamento do protocolo SMB.

Bash
use auxiliary/scanner/smb/smb_ms17_010
set RHOSTS 192.168.1.126
run
(Nota: Embora esse módulo seja para o EternalBlue do Windows, ele é excelente para retornar o "OS Fingerprint" de sistemas Linux rodando Samba também).

1. Pegar a Versão do Apache (HTTP)
Esse é fundamental para saber se o servidor web tem alguma CVE.

Bash
use auxiliary/scanner/http/http_version
set RHOSTS 192.168.1.126
run
2. Tentar o SMB de outra forma
Já que o ms17_010 falhou no login, vamos usar o módulo de versão padrão, que é mais "gentil":

Bash
use auxiliary/scanner/smb/smb_version
set RHOSTS 192.168.1.126
run



### 1. Enumeração de Conteúdo Web (The Hidden Files)

Você sabe que o Apache está lá, mas não sabe o que tem _dentro_ dele. Às vezes, desenvolvedores esquecem arquivos como `.env`, `config.php` ou pastas de backup. **O que fazer:**

Bash

```
use auxiliary/scanner/http/dir_scanner
set RHOSTS 192.168.1.126
run
```

_Procure por códigos 200 (OK) em pastas que não sejam as padrões._

### 2. Verificação de Vulnerabilidades SMB (Nmap Scripts)

Como o Metasploit deu erro no `ms17_010` (porque é um Linux), vale a pena usar o Nmap (através do pivô ou se você tiver ele no Kali) para rodar scripts de enumeração mais agressivos no Samba para ver se ele aceita **Guest Access** em alguma pasta específica. **O que fazer (no console do MSF):**

Bash

```
use auxiliary/scanner/smb/smb_enumshares
set RHOSTS 192.168.1.126
run
```

_Isso vai nos dizer se o usuário `zafire` deixou alguma pasta como "Public" ou "Downloads" com leitura liberada._