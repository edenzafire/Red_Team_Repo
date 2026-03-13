# 📑 Guia de Preparação Forense - Trace Labs VM

**Projeto:** Self-Hacking Lab / OSINT Recon  
**Local de Armazenamento:** ~/Desktop/TL-Vault/01_Osint/

## 1. Início da Sessão (Preservação de Logs)

Antes de rodar qualquer ferramenta, inicie a captura do terminal para garantir que cada comando e resposta seja registrado.

```
script ~/Desktop/TL-Vault/01_Osint/evidences/sessao_recon_$(date +%d-%m-%y).log

```

## 2. Verificação de Ambiente (Checklist)

- [ ] VPN Ativa (Se aplicável)
    
- [ ] Obsidian aberto no Vault 01_Osint
    
- [ ] Terminal em modo script (Passo anterior)
    

## 3. Protocolo de Integridade (Hashing)

Após gerar qualquer relatório de ferramenta (ex: .txt ou .json), gere o hash SHA-256 para garantir que a evidência não foi adulterada para o portfólio.

# Gerar hash de um arquivo específico

sha256sum nome_do_arquivo.txt >> ~/Desktop/TL-Vault/01_Osint/hashes_evidencias.txt

## 4. Comandos Essenciais de Recon

1. **Sherlock:** sherlock ALVO --timeout 15
    
2. **theHarvester:** theHarvester -d ALVO -l 500 -b google,bing
    
3. **Whois:** whois ALVO
    

## 5. Finalização da Coleta

Para encerrar a gravação do log e salvar o arquivo:
