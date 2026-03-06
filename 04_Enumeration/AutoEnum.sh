#!/bin/bash

## Formato: ./AutoEnum.sh <IP_ALVO> <NOME_PARA_O_RELATORIO>
#./AutoEnum.sh 192.168.x.y Alvo01_Apache
# AutoEnum v1.0 - Estrutura de Pentest Profissional
# Autor: Nikolay (debian12RED)

TARGET=$1
PROJECT_NAME=$2

if [ -z "$TARGET" ] || [ -z "$PROJECT_NAME" ]; then
    echo "Uso: ./AutoEnum.sh <IP_DO_ALVO> <NOME_DO_PROJETO>"
    exit 1
fi

# Criando estrutura de pastas para o Obsidian
mkdir -p ./evidencias/$PROJECT_NAME/nmap
mkdir -p ./evidencias/$PROJECT_NAME/web

echo -e "\033[1;31m[+] Iniciando Varredura Nmap em $TARGET...\033[0m"
nmap -sV -sC -Pn -T4 $TARGET -oN ./evidencias/$PROJECT_NAME/nmap/full_scan.txt

# Verifica se a porta 80 está aberta para rodar Gobuster
if grep -q "80/tcp" ./evidencias/$PROJECT_NAME/nmap/full_scan.txt; then
    echo -e "\033[1;34m[+] Porta 80 detectada! Iniciando Gobuster...\033[0m"
    gobuster dir -u http://$TARGET -w /usr/share/wordlists/dirb/common.txt -o ./evidencias/$PROJECT_NAME/web/directories.txt
fi

echo -e "\033[1;32m[!] Enumeração concluída. Arquivos salvos em ./evidencias/$PROJECT_NAME/\033[0m"
