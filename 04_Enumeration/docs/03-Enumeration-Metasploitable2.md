# Relatório Técnico: Enumeração Profunda de Alvo Crítico

**ID:** 04-ENUM-METASPLOITABLE2

**Operador:** Nikolay (Lab Environment)

**Alvo:** 192.168.1.145

**Pivoting via:** 192.168.1.113 (WIN10-LAB)

**Framework:** MITRE ATT&CK (T1046, T1595.002, T1210)

---

## 0x01. Sumário Executivo

Este documento detalha a fase de enumeração do host **Metasploitable 2**, identificado através de pivô na rede interna. O sistema apresenta uma superfície de ataque legada (Ubuntu 8.04), operando com serviços propositalmente vulneráveis e sem patches de segurança. Foram confirmados múltiplos vetores de **RCE (Remote Code Execution)** e um **Backdoor de Root** ativo.

---

## 0x02. Timeline de Execução (Metodologia)

Seguindo o fluxo operacional de exploração, a enumeração foi dividida por protocolos para garantir a captura de banners e versões exatas.

1. **Varredura Inicial:** Identificação de portas abertas via túnel Meterpreter.
    
2. **Fingerprinting:** Coleta de banners de serviços críticos (FTP, SSH, SMB, MySQL, Java RMI).
    
3. **Mapeamento Web:** Enumeração de diretórios e interfaces de gerenciamento (phpMyAdmin).
    

---

## 0x03. Descobertas Técnicas (Evidências)

### A. Serviço FTP (Porta 21) - Backdoor Detectado

A identificação da versão do serviço revelou o vetor mais crítico do sistema.

- **Serviço:** vsFTPd 2.3.4
    
- **Risco:** Crítico (RCE como Root).
    
- **Evidência Técnica:** 
![01varreduraFTP.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/03Metasploitable/01varreduraFTP%20.png)
    
- **Análise:** O banner confirma a versão vulnerável ao backdoor `:)` na autenticação, permitindo bypass total de controle.
    

### B. Serviços SMB e SSH (Portas 445/22)

Identificação de versões para busca de exploits de transbordamento de buffer ou má configuração.

- **Samba:** Versão 3.0.20 (Unix).
    
- **SSH:** OpenSSH 4.7p1 Debian.
    
- **Evidência Técnica (SMB):** 
![02SMBServices.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/03Metasploitable/02SMBServices.png)
    
- **Evidência Técnica (SSH):**
![03SSHVersion.jpg]()
    

### C. Camada Web e Banco de Dados (Portas 80/3306)

Enumeração de diretórios e versões de database.

- **HTTP:** Identificado diretório `/phpMyAdmin/` funcional.
    
- **MySQL:** Versão 5.0.51a-3ubuntu5.
    
- **Evidência Técnica (HTTP):**
![04HttpEnum.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/03Metasploitable/04HttpEnum.png)
    
- **Evidência Técnica (MySQL):** 
![05MySqlVersion.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/03Metasploitable/05MySqlVersion.png)


    

### D. Java RMI (Porta 1099)

- **Serviço:** GNU Classpath grmiregistry.
    
- **Evidência Técnica:** 
![06JavaRMIVersion.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/03Metasploitable/06JavaRMIVersion.png)
    
- **Análise:** Serviço suscetível a ataques de desserialização Java.
    

---

## 0x04. Matriz de Vulnerabilidades Identificadas

|**Serviço**|**Versão**|**CVE Referência**|**Impacto**|
|---|---|---|---|
|**FTP**|vsFTPd 2.3.4|CVE-2011-2523|**Comprometimento Total (Root)**|
|**Samba**|3.0.20|CVE-2007-2447|**Execução Remota de Código**|
|**MySQL**|5.0.51a|CVE-2012-2122|Acesso não autorizado a dados|

---

## 0x05. Conclusão Operacional

O host 192.168.1.145 não possui defesas ativas (IPS/IDS ou Firewall host-based). O vetor de ataque prioritário para a fase **05_Vulnerability_Research** é o serviço **vsFTPd 2.3.4**, seguido pela exploração do **Samba (UserMap Script)**. Ambos garantem persistência e privilégios elevados.

---

**Log Completo da Sessão:** [EnumMetasploitable.log](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/03Metasploitable/EnumMetasploitable.log)


---
