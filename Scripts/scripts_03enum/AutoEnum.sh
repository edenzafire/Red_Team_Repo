#!/bin/bash

# AutoEnum.sh - Automatização de Enumeração PTES
# Uso: ./AutoEnum.sh -t 192.168.x.x

while getopts t: flag
do
    case "${flag}" in
        t) target=${OPTARG};;
    esac
done

if [ -z "$target" ]; then
    echo "[-] Erro: Use -t para definir o IP do alvo."
    exit 1
fi

# Criando estrutura de pastas para o Portfólio
mkdir -p ./evidencias/$target/{nmap,web}

echo "[+] Iniciando Enumeração Master para: $target"

# Passo 1: Nmap Rápido (Apenas Portas Abertas)
echo "[*] Identificando portas abertas..."
ports=$(nmap -p- --min-rate 1000 -T4 $target | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed 's/,$//')

if [ -z "$ports" ]; then
    echo "[-] Nenhuma porta encontrada. Saindo."
    exit 1
fi

echo "[+] Portas encontradas: $ports"

# Passo 2: Nmap Profundo (Versões e Scripts) nas portas achadas
echo "[*] Fazendo Banner Grabbing e Service Detection..."
nmap -sV -sC -p$ports $target -oN ./evidencias/$target/nmap/deep_scan.txt

# Passo 3: Se a porta 80 ou 443 estiver aberta, roda Gobuster
if [[ $ports == *"80"* ]] || [[ $ports == *"443"* ]]; then
    echo "[*] Porta Web detectada! Iniciando Gobuster..."
    gobuster dir -u http://$target -w /usr/share/wordlists/dirb/common.txt -q -o ./evidencias/$target/web/directories.txt
fi

echo "[+] Enumeração Concluída! Resultados em ./evidencias/$target/"
