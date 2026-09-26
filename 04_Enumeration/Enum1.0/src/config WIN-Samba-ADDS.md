
🛠️ Passo 2: Criando os Usuários "Vítimas"
No terminal administrativo, digite os seguintes comandos (um por um):

Para o setor Financeiro:

DOS
net user "Financeiro_Maria" "Senha@123" /add
Para a equipe de Suporte:

DOS
    net user "Suporte_TI" "Suporte#2026" /add
    ```

> [!TIP]
> **Dica de mestre:** Se você quiser que o suporte tenha poderes administrativos (o que seria um "presente" para sua escalação de privilégios depois), rode também:
> `net localgroup administrators "Suporte_TI" /add`

---

### 🛠️ Passo 3: Criando o "Bait" (O rastro de dados)
A enumeração fica muito mais bonita quando você encontra arquivos reais. Vamos criar o conteúdo que você vai "roubar" depois via Meterpreter:

1.  Faça **Logoff** do seu usuário atual e entre como **Financeiro_Maria**.
2.  Na Área de Trabalho dela, crie uma pasta chamada `Planilhas_Sensiveis`.
3.  Dentro da pasta, crie um arquivo chamado `contas_a_pagar.txt` e escreva algo como: *"Pagamento fornecedor: R$ 50.000,00"*.
4.  Isso vai permitir que você use o comando `search -f *.txt` depois no Metasploit para encontrar "tesouros".
5. 
```
net user vboxuser Vbox@2026
net user "Financeiro_Maria" "Senha@123" /add
net user "Suporte_TI" "Suporte#2026" /add
net localgroup administradores "Suporte_TI" /add
``` 
### 🔍 Por que o Samba "não deu certo" ali?

1. **Sintaxe do Caminho:** No Windows, para acessar uma pasta compartilhada (Samba/SMB) via IP, você precisa usar as barras invertidas duplas no início. Se você apenas digitar o IP, o Windows acha que você está procurando um arquivo com esse nome no computador local.
    
2. **O jeito certo:** Você deve digitar `\\192.168.1.126` na barra de endereços (e não na de pesquisa).
    

---

### 🛠️ Como resolver isso e documentar no Obsidian:

Para o seu relatório de **Movimentação Lateral**, é importante mostrar que você sabe acessar compartilhamentos de rede.

1. **Abra o "Executar":** Pressione `Windows + R` na VM.
    
2. **Digite o caminho SMB:** `\\192.168.1.126` e dê Enter.
    
3. **Configuração do Servidor:** Se mesmo assim não abrir, pode ser que o serviço Samba no seu servidor Debian (onde está o ADDS/Apache) não esteja configurado para aceitar conexões anônimas ou o firewall esteja bloqueando as portas **139** e **445**.