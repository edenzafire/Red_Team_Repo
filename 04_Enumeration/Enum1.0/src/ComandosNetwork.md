### Passo 1: Preparar o Pivô (Meterpreter)

Antes de escanear, você precisa garantir que o Metasploit sabe como rotear o tráfego através da máquina comprometida.

1. **Verifique sua sessão:** No console do msf, certifique-se de que a sessão 1 está ativa.
    
2. **Configure a Rota:**
    
    Bash
    
    ```
    # No console do MSF (fora do meterpreter) ou use 'run' dentro dele
    route add 192.168.1.0 255.255.255.0 1
    # Isso diz ao Metasploit: "Para qualquer IP 192.168.1.X, use a Sessão 1 como túnel".
    ```
    

### Passo 2: Varredura de Descoberta (Host Discovery)

Agora vamos forçar o Windows a "gritar" na rede para popular o cache ARP que estava vazio.

1. **No Meterpreter, execute o script de ARP Scanner:**
    
    Bash
    
    ```
    meterpreter > run post/windows/gather/arp_scanner RHOSTS=192.168.1.0/24
    ```
    
    - **O que esperar:** Aqui devem aparecer o **192.168.1.126** (Macbook) e o IP do **Metasploitable2**.
        
    - **Ação:** Tire um print deste resultado! Ele será a sua **Figura 1** do novo relatório.
        

### Passo 3: Escaneamento de Portas e Versões (Service Discovery)

Agora que você sabe que eles estão "vivos", vamos descobrir o que está rodando neles (como o Apache que você mencionou).

1. **Coloque a sessão em background:** `ctrl+z` e depois `y`.
    
2. **Use o scanner de portas TCP:**
    
    Bash
    
    ```
    msf > use auxiliary/scanner/portscan/tcp
    msf > set RHOSTS 192.168.1.126, <IP_DO_METASPLOITABLE>
    msf > set PORTS 21,22,80,443,445,3306
    msf > set THREADS 10
    msf > run
    ```
    
3. **Identifique as versões (Crucial para o passo 05 - Vulnerability Research):**
    
    Bash
    
    ```
    msf > use auxiliary/scanner/http/http_version
    msf > set RHOSTS 192.168.1.126
    msf > run
    ```
    
    - **Ação:** O resultado aqui confirmará se é o **Apache 2.4** ou outra versão. Guarde essa informação para a pesquisa de exploits.
        

### Passo 4: Varredura de SMB (Para o Metasploitable2)

Como o Metasploitable é focado em falhas de rede, verifique o SMB:

Bash

```
msf > use auxiliary/scanner/smb/smb_version
msf > set RHOSTS <IP_DO_METASPLOITABLE>
msf > run
```

##################################################3


1. Preparar a Rota (Pivoting)
Antes de rodar scanners, o Metasploit precisa saber que deve enviar o tráfego através da sua sessão ativa.

Comando:

Bash
meterpreter > run autoroute -s 192.168.1.0/24
Por que? Isso cria um túnel. Sem isso, o Metasploit tentará escanear a partir da sua própria máquina (Kali/Debian) e não encontrará nada, pois o alvo está escondido atrás do Windows.

2. Descoberta de Hosts (O "Pulo do Gato")
Este é o comando que vai fazer o Macbook e o Metasploitable aparecerem. Ele envia requisições ARP para todos os IPs da rede.

Comando:

Bash
meterpreter > run post/windows/gather/arp_scanner RHOSTS=192.168.1.0/24
Ação: Quando aparecer a lista de IPs e MAC addresses, tire o primeiro print. Este é o coração do seu novo relatório.

3. Escaneamento de Portas (TCP Scan)
Agora que você confirmou que o IP 192.168.1.126 (Macbook) e o do Metasploitable estão ativos, vamos ver o que tem aberto. Coloque a sessão em segundo plano primeiro.

Comandos:

Bash
meterpreter > background
msf6 > use auxiliary/scanner/portscan/tcp
msf6 > set RHOSTS 192.168.1.126, <IP_DO_METASPLOITABLE>
msf6 > set PORTS 21,22,80,443,445,3306
msf6 > run
4. Identificação de Versão (Para o Passo 05 - Vulnerability Research)
Como você mencionou que o próximo passo é a pesquisa de vulnerabilidades, você precisa saber a versão exata do Apache no Macbook.

Comandos:

Bash
msf6 > use auxiliary/scanner/http/http_version
msf6 > set RHOSTS 192.168.1.126
msf6 > run
Ação: Tire um print do resultado que mostrar algo como Apache/2.4.XX. Esse dado é o que você vai usar para buscar exploits no Google ou no Searchsploit depois.

### Passo Atual: Descoberta de Hosts (ARP Scan)

Execute exatamente este comando agora:

Bash

```
meterpreter > run post/windows/gather/arp_scanner RHOSTS=192.168.1.0/24
```

**O que fazer em seguida:**

1. **Espere concluir:** Ele vai varrer do IP .1 ao .254.
    
2. **Identifique os alvos:** Procure na lista pelo IP **192.168.1.126** (seu Macbook) e veja qual outro IP aparece (que será o seu Metasploitable2).
    
3. **PRINT:** Tire um print dessa tela assim que os resultados aparecerem. Esse é o documento central para provar a existência dos alvos no seu relatório de **Network Scanning**.
    

**Dica técnica:** Se o Metasploit disser que o comando não foi encontrado, tente apenas `run arp_scanner RHOSTS=192.168.1.0/24`.

###################################33

### Como achar o Metasploitable2 agora?

Como o `arp_scanner` (que é nível 2 - Link Layer) não o listou, vamos subir um nível e usar o **ICMP (Ping)** e o **TCP Scan** através do pivô.

**Siga estes passos agora:**

1. **Mande a sessão para background:**
    
    Bash
    
    ```
    meterpreter > background
    ```
    
2. **Use o scanner de portas no range inteiro:** (Isso vai demorar uns 2 minutos, mas vai varrer a rede toda atrás de portas comuns de servidor, como a 80 ou 22).
    
    Bash
    
    ```
    msf6 > use auxiliary/scanner/portscan/tcp
    msf6 > set RHOSTS 192.168.1.0/24
    msf6 > set PORTS 22,80,445,3306
    msf6 > set THREADS 20
    msf6 > run
    ```
Ops! Aconteceu um erro clássico de sintaxe. O prefixo `msf6 >` que eu usei no exemplo é apenas a indicação do terminal (o prompt), você não deve digitar ele! O Metasploit entendeu que `msf6` era o comando, e por isso deu "Unknown command".

Como você já está no `msf exploit(multi/handler)`, basta digitar os comandos diretamente. Vamos corrigir isso agora:

### Digite exatamente assim:

1. **Selecionar o Scanner:**
    
    Bash
    
    ```
    use auxiliary/scanner/portscan/tcp
    ```
    
2. **Configurar os Alvos (a rede toda):**
    
    Bash
    
    ```
    set RHOSTS 192.168.1.0/24
    ```
    
3. **Configurar as Portas (as mais comuns do Metasploitable):**
    
    Bash
    
    ```
    set PORTS 21,22,23,80,445,3306
    ```
    
4. **Aumentar a velocidade:**
    
    Bash
    
    ```
    set THREADS 20
    ```
    
5. **Executar:**
    
    Bash
    
    ```
    run
    ```

######################

### Próximo Comando de Elite:

Para fechar o relatório de rede com chave de ouro e preparar o terreno para a pesquisa de vulnerabilidades, vamos descobrir a **versão exata** do que está rodando no Macbook:

Bash

```
use auxiliary/scanner/http/http_version
set RHOSTS 192.168.1.126
run
```

E depois para o SMB (já que a 445 apareceu aberta):

Bash

```
use auxiliary/scanner/smb/smb_version
set RHOSTS 192.168.1.126
run
```

### Comandos de Finalização (Pegar as Versões para o Passo 05):

Para o seu próximo relatório de vulnerabilidades ser "estilo elite", você não pode dizer apenas "a porta está aberta". Você precisa dizer: "o serviço **Versão X** está rodando".

Rode estes últimos comandos e tire prints:

**1. Identificar o "recheio" do Metasploitable2:**

Bash

```
use auxiliary/scanner/http/http_version
set RHOSTS 192.168.1.126, 192.168.1.145
run
```

**2. Verificar o SMB (muito importante para o Metasploitable):**

Bash

```
use auxiliary/scanner/smb/smb_version
set RHOSTS 192.168.1.126, 192.168.1.145
run
```

**3. Verificar o FTP (vetor clássico do Metasploitable):**

Bash

```
use auxiliary/scanner/ftp/ftp_version
set RHOSTS 192.168.1.145
run
```

### Vamos finalizar o `Network_Scanning.md`?

Para fechar esse com chave de ouro, você só precisa de um último "pente fino" de versões. Como você já rodou o portscan, execute estes dois comandos rápidos para ter os dados finais:

**No console do MSF:**

Bash

```
# Pegar a versão do Apache do Macbook e do Metasploitable
use auxiliary/scanner/http/http_version
set RHOSTS 192.168.1.126, 192.168.1.145
run

# Pegar as versões de SMB (que apareceram abertas em ambos)
use auxiliary/scanner/smb/smb_version
set RHOSTS 192.168.1.126, 192.168.1.145
run
```

#####################

Siga estes passos finais no console para coletar os últimos dados:

### 1. Identificar Versões de HTTP (Essencial para o Macbook)

Isso vai nos dizer se o Apache é antigo e tem exploits conhecidos.

Bash

```
use auxiliary/scanner/http/http_version
set RHOSTS 192.168.1.126, 192.168.1.145
run
```

### 2. Identificar Versões de SMB (Essencial para os dois)

Como ambos estão com a porta 445 aberta, precisamos saber a versão do Samba/SMB.

Bash

```
use auxiliary/scanner/smb/smb_version
set RHOSTS 192.168.1.126, 192.168.1.145
run
```

### 3. Identificar Versão de FTP (Específico para o Metasploitable)

A porta 21 no Metasploitable é famosa por ter um backdoor na versão `vsftpd 2.3.4`.

Bash

```
use auxiliary/scanner/ftp/ftp_version
set RHOSTS 192.168.1.145
run
```

