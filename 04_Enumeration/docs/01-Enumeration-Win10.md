# Relatório de Inteligência Técnica: Enumeração e Persistência

**Operação:** Luthieria Flamenca

**Alvo:** WIN10-LAB (192.168.1.113)

**Data:** 15 de Maio de 2026

**Status:** Consolidado

---

## 0x01. Resumo Executivo

Após o acesso inicial, procedeu-se com a enumeração completa do host alvo. A análise confirmou um ambiente Windows 10 Pro virtualizado em **pt_PT**. Foram identificadas táticas de persistência via masquerading e mapeada a topologia de rede local para movimentação lateral. O sistema apresenta-se atualizado, porém com configurações de firewall que permitem comunicação externa via C2.

---

## 0x02. Táticas, Técnicas e Procedimentos (MITRE ATT&CK)

|**Tática**|**ID**|**Técnica**|**Observação**|
|---|---|---|---|
|**Reconnaissance**|T1590|Gather Victim Network Info|Coleta de IPs, MAC e Cache ARP (Imagens 03 e 08).|
|**Discovery**|T1082|System Information Discovery|Identificação do SO e Build 19045 (Imagem 01).|
|**Discovery**|T1497|Virtualization/Sandbox Evasion|Identificação de ambiente VirtualBox.|
|**Discovery**|T1012|Query Registry|Verificação de privilégios e usuários locais (Imagem 06).|
|**Defense Evasion**|T1562.001|Disable or Modify Tools|Verificação do estado do Firewall (Imagem 07).|
|**Command and Control**|T1071.001|Web Protocols|Comunicação via porta 4444 (Imagem 04).|

---

## 0x03. Evidências Técnicas (Análise de Host)

### 3.1 Identificação do Sistema e Contexto

O alvo foi confirmado como um Windows 10 x64. A sessão foi estabelecida no contexto do usuário `vboxuser`, que possui privilégios administrativos.

![01Sysinfo.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/01Win10/01Sysinfo.png)

_Figura 1: Coleta de informações do sistema._

![02Getuid.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/01Win10/02Getuid.png)

_Figura 2: Verificação do contexto de usuário atual._

### 3.2 Configurações de Rede e Firewall

O adaptador Intel PRO/1000 opera no IP `192.168.1.113`. O firewall está ativo, porém permite o tráfego de saída do beacon.

![03Ipconfig.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/01Win10/03Ipconfig.png)

_Figura 3: Configuração de interfaces de rede._

![07StatusFirewall.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/01Win10/07StatusFirewall.png)

_Figura 4: Auditoria do estado do Windows Firewall._

---

## 0x04. Persistência e Processos

A persistência é mantida pelo binário `WindowsUpdater.exe`, camuflado na árvore de processos para simular uma atualização legítima do Windows.

![04Netstat.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/01Win10/04Netstat.png)

_Figura 5: Conexão ativa (ESTABLISHED) com o C2 (192.168.1.143)._

![05Ps.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/01Win10/05Ps.png)

_Figura 6: Mapeamento de PIDs e caminhos de execução dos processos._

---

## 0x05. Matriz de Usuários e Atualizações

A enumeração revelou os grupos administrativos locais. O sistema possui patches instalados até a data presente (Maio de 2026).

![06EnumUsers.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/01Win10/06EnumUsers.png)

_Figura 7: Identificação de usuários e grupos locais (pt_PT)._

![09PatchesDeSeguranca.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/01Win10/09PatchesDeSeguranca.png)

_Figura 8: Listagem de Hotfixes instalados (WMIC QFE)._

---

## 0x06. Inteligência de Rede e Próximos Passos

### Análise do Cache ARP

> **Insight Crítico:** Durante a varredura do cache ARP, o host **MACBOOK-SRV** não foi detectado. Isso indica que o dispositivo pode estar em _sleep mode_, isolado por isolamento de porta (PVLAN) ou simplesmente não houve tráfego recente entre as máquinas.

![08Arp.jpg](https://github.com/edenzafire/Red_Team_Repo/blob/main/04_Enumeration/evidences/01Win10/08Arp.png)

_Figura 9: Mapeamento de vizinhança de rede (Cache ARP)._

**Próximas Ações:**

1. **Varredura Ativa:** Iniciar `nmap -sn 192.168.1.0/24` para forçar a descoberta do Macbook.
    
2. **Pivoting:** Utilizar a sessão atual para atacar o **Metasploitable2** e o **Active Directory** identificados na rede interna.
    
3. **Credential Dumping:** Realizar o dump de hashes para capturar a senha do usuário `Suporte_TI`.
)
