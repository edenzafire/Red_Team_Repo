# Relatório Técnico de Enumeração e Movimentação Lateral
## Alvo 01 – Windows 10 Pro (Rede Interna)

**Author:** Zafire Daniel / Nikolay (Lab Environment)  
**Data:** 28 de Fevereiro de 2026  
**MITRE ATT&CK:** T1046, T1021.002, T1021.006  
**Status:** Em Andamento  
**Ambiente:** Rede Interna (Pivoting via MAC-DEBIAN-SRV)

---

# 1. Executive Summary

Este relatório descreve a enumeração do primeiro  alvo na cadeia de ataque, o host **WIN10-CLIENT-01**. O acesso a este ativo foi viabilizado através da fase 03_Social_Enginering onde foi encaminhado um Prishing direcionado para o e-mail e****d*****@***.com ############################################################.

 #  1.1 Persistence
O objetivo neste primeiro momento é estabelecer a persistência neste primeiro dispositivo, para que caso a vitima desligue o aparelho não percamos a comunicação.

 #1.2 Reconoissence
 Após o estabelecimento da persistência, em nosso alvo, foi necessário realizar um reconhecimento, do ambiente em que estou para assim, partir para as próximas fazes deste  projeto.
 * foi utilizado  para o reconhecimento as seguintes ferramentas, e comandos.
 * 
 

---

# 2. Escopo
Através da varredura acima foi descoberto o seguinte:

**Host Alvo:**
- **Hostname:** WIN10-CLIENT-01
- **IP:** 192.168.x.z (Rede Interna)
- **OS:** Windows 10 Pro
- **Contexto:** Estação de trabalho cliente.

**Objetivo:**
Identificar serviços de gerenciamento remoto e compartilhamentos de rede que permitam o salto (hop) do servidor web para a rede de usuários.

---

# 3. Metodologia

A enumeração foi realizada de forma indireta (através do túnel estabelecido no Alvo 01), focando em:
1.  **Network Service Scanning:** Descoberta de portas TCP específicas do ecossistema Windows.
2.  **SMB Interaction:** Verificação de permissões de compartilhamento e IPC$.
3.  **Remote Management Analysis:** Validação de endpoints PowerShell Remoting (WinRM).

---

# 4. Timeline Técnica

* **T+01:05** – Estabelecimento do túnel de rede para a sub-rede interna.
* **T+01:15** – Início da varredura de portas SMB (139/445) e WinRM (5985).
* **T+01:30** – Execução do script de descoberta de SO via Nmap.
* **T+01:45** – Enumeração detalhada de usuários e grupos via `enum4linux-ng`.

---

# 5. Descobertas Técnicas

## 5.1 Enumeração de SMB (Server Message Block)

### Técnica MITRE
	**T1021.002** – Remote Services: SMB/Windows Admin Shares 

### Comando Executado
```bash
nmap -p 139,445 --script smb-os-discovery,smb-enum-shares 192.168.x.z
```

---

## 5. Descobertas Técnicas (Continuação)

### 5.1 Enumeração de SMB (Server Message Block)

**Análise:**
A presença do SMB ativo é um vetor crítico. A análise buscou identificar se o "Guest Access" (acesso convidado) está habilitado ou se há compartilhamentos administrativos (`C$`, `ADMIN$`) visíveis, o que facilitaria a exfiltração de dados ou movimentação lateral.

---

### 5.2 Enumeração de WinRM (Windows Remote Management)

**Técnica MITRE:**
T1021.006 – Remote Services: Windows Remote Management

**Comando Executado:**
```bash
nmap -p 5985,5986 -sV 192.168.x.z
```
### Análise Técnica
O serviço **WinRM** na porta **5985** confirma que o host está preparado para gerenciamento remoto via **PowerShell Remoting**.

* **Impacto:** Caso credenciais sejam capturadas no Alvo 01 ou através de ataques de rede como **LLMNR poisoning**, este serviço permite a obtenção de uma shell interativa de alta performance no Windows, facilitando a execução de scripts de pós-exploração.

---

## 6. Análise de Risco e Impacto

> [!CAUTION]
> **Impacto no Negócio:** O comprometimento de uma estação Windows 10 Pro frequentemente leva à captura de **hashes NTLM** e **tickets Kerberos**. Se o usuário logado possuir privilégios elevados (como um Administrador de Domínio), todo o ambiente (AD DS) estará em risco crítico de **Domain Takeover** (comprometimento total do domínio).

---

## 7. Recomendações de Mitigação

### 7.1 Defesa Local (Hardening)
* **SMB:** Desativar o protocolo legado SMBv1 e restringir o acesso a compartilhamentos administrativos (`C$`, `ADMIN$`) apenas para IPs de gerência autorizados.
* **WinRM:** Configurar o WinRM para aceitar exclusivamente conexões via **HTTPS (porta 5986)** e exigir autenticação baseada em certificados ou Kerberos forte.

### 7.2 Defesa de Rede (Blue Team)
* **Micro-segmentação:** Implementar regras de firewall para impedir que servidores localizados na DMZ (como o Alvo 01) iniciem conexões diretas para as portas **445** e **5985** das estações de trabalho da rede interna.
* **Monitoramento:** Implementar alertas SIEM para tentativas de login falhas (**Event ID 4625**) originadas especificamente do endereço IP do servidor Apache.

---

## 8. Apêndice – Evidências

* **Evidence 01:** `[./evidencias/win10/smb_scan.png]` – Resultados da enumeração de compartilhamentos e sessões SMB.
* **Evidence 02:** `[./evidencias/win10/winrm_port.png]` – Captura do banner do serviço WinRM identificado durante a varredura.

---
