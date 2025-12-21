#!/usr/bin/env python3
# darkweb_monitor_masked.py - Versão para Portfólio Público (GitHub)

import requests
import socks
import socket
import re
import json
import argparse
from bs4 import BeautifulSoup
from stem import Signal
from stem.control import Controller

# Mascara dados sensíveis
def mask_sensitive(data):
    # Emails: joao.silva@gmail.com → joao.s****@g****.com
    data = re.sub(r'([a-zA-Z0-9._%+-]{2,})@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})',
                  r'\1@**\2', data)
    # CPFs: 123.456.789-00 → ***.456.789-**
    data = re.sub(r'\d{3}\.\d{3}\.\d{3}-\d{2}', '***.***.***-**', data)
    # Senhas/hashes longos
    data = re.sub(r'\b[a-f0-9]{32,}\b', '[HASH_MASCARADO]', data, flags=re.IGNORECASE)
    return data

# Roteia via Tor
def setup_tor():
    socks.setdefaultproxy(socks.PROXY_TYPE_SOCKS5, "127.0.0.1", 9050)
    socket.socket = socks.socksocket

# Renova circuito Tor (opcional, pra anonimato extra)
def renew_tor_circuit():
    with Controller.from_port(port=9051) as controller:
        controller.authenticate()
        controller.signal(Signal.NEWNYM)

def collect_and_mask(url, keywords):
    setup_tor()
    headers = {'User-Agent': 'Mozilla/5.0 (compatible; OSINT-Tool/1.0)'}
    
    try:
        response = requests.get(url, headers=headers, timeout=40)
        soup = BeautifulSoup(response.text, 'html.parser')
        text = soup.get_text()
        
        findings = []
        for keyword in keywords:
            if keyword.lower() in text.lower():
                # Pega contexto ao redor da keyword
                start = max(0, text.lower().find(keyword.lower()) - 100)
                end = min(len(text), text.lower().find(keyword.lower()) + len(keyword) + 200)
                snippet = text[start:end]
                masked_snippet = mask_sensitive(snippet)
                findings.append({
                    "keyword": keyword,
                    "context": masked_snippet,
                    "url": url
                })
        
        return findings
    except Exception as e:
        return [{"error": str(e)}]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Monitoramento OSINT Darkweb - Versão Portfólio (Mascarada)")
    parser.add_argument('--url', required=True, help="URL .onion do fórum/mercado")
    parser.add_argument('--keywords', nargs='+', default=['.br', 'gov.br', 'banco'], help="Palavras-chave para monitorar")
    parser.add_argument('--output', default='darkweb_monitor_report.json')
    
    args = parser.parse_args()
    
    print("[+] Coletando e mascarando dados...")
    results = collect_and_mask(args.url, args.keywords)
    
    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=4, ensure_ascii=False)
    
    print(f"[+] Relatório mascarado salvo em {args.output}")
