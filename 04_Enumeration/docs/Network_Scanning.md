# Relatório de Varredura de Rede (Network Scanning)

**ID:** 04-NET-SCAN

**Operador:** Nikolay (Red Team)

**Data:** 15 de Maio de 2026

**Alvo Inicial (Pivot):** 192.168.1.113 (WIN10-LAB)

---

## 0x01. Sumário Executivo

Após o comprometimento bem-sucedido do host **WIN10-LAB**, foi realizada uma varredura de rede interna para identificar novos ativos e vetores de ataque. A operação utilizou técnicas de _Pivoting_ para contornar segmentações básicas e mapear serviços críticos em máquinas anteriormente invisíveis ao console de ataque principal.

## 0x02. Mapeamento MITRE ATT&CK

|**Tática**|**Técnica**|**ID**|**Descrição**|
|---|---|---|---|
|**Discovery**|Network Service Scanning|[T1046](https://attack.mitre.org/techniques/T1046/)|Varredura de portas TCP para identificar serviços em execução.|
|**Discovery**|Network Information Discovery|[T1016](https://attack.mitre.org/techniques/T1016/)|Uso de varredura ARP para listar dispositivos ativos no segmento local.|
|**Discovery**|System Network Connections Discovery|[T1018](https://attack.mitre.org/techniques/T1018/)|Identificação de hosts vizinhos através da tabela ARP do pivô.|

---

## 0x03. Metodologia de Varredura

### 1. Estabelecimento de Rota (Pivoting)

A sessão Meterpreter no host `192.168.1.113` foi utilizada para rotear o tráfego do Metasploit Framework para a sub-rede `192.168.1.0/24`.

- **Comando:** `run autoroute -s 192.168.1.0/24`
    
- **Evidência:** [01PreparandoArota.jpg](https://www.google.com/search?q=01PreparandoArota.jpg)
    

### 2. Descoberta de Hosts (ARP Scan)

Varredura de nível 2 para identificar dispositivos ativos no segmento.

- **Hosts Identificados:**
    
    - `192.168.1.126`: Macbook-SRV (Apple Computer Inc.)
        
    - `192.168.1.145`: Metasploitable 2
        
- **Evidência:** [02Primeiravarredura.jpg](https://www.google.com/search?q=02Primeiravarredura.jpg)
    

---

## 0x04. Inventário de Serviços e Versões (Fingerprinting)

Com base na varredura de portas (`portscan/tcp`) e identificação de versões, os seguintes dados foram consolidados:

|**IP**|**Sistema**|**Porta**|**Serviço**|**Versão / Banner**|**Link do Print**|
|---|---|---|---|---|---|
|**192.168.1.126**|Macbook-SRV|80|HTTP|**Apache/2.4.67 (Debian)**|[04varreduraServicos.jpg](https://www.google.com/search?q=04varreduraServicos.jpg)|
|||445|SMB|SMB 3.1.1 (Samba 6.1.0)|[06SmbVersion.jpg](https://www.google.com/search?q=06SmbVersion.jpg)|
|**192.168.1.145**|Metasploitable 2|21|FTP|**vsFTPd 2.3.4**|[07FtpVersion.jpg](https://www.google.com/search?q=07FtpVersion.jpg)|
|||80|HTTP|Apache/2.2.8 (PHP/5.2.4)|[04varreduraServicos.jpg](https://www.google.com/search?q=04varreduraServicos.jpg)|
|||445|SMB|Samba (Unix)|[06SmbVersion.jpg](https://www.google.com/search?q=06SmbVersion.jpg)|

---

## 0x05. Conclusão Técnica

A fase de enumeração confirmou o **Metasploitable 2 (192.168.1.145)** como o alvo de maior prioridade devido à presença do backdoor no **vsFTPd 2.3.4**. O **Macbook-SRV (192.168.1.126)** apresenta superfícies de ataque em SMB e Apache que serão investigadas na próxima fase.
