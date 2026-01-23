# 🏗️ Lab Infrastructure & Network Topology

![Lab Status: Active](https://img.shields.io/badge/Lab_Status-Active-brightgreen?style=for-the-badge)
![Environment: Hybrid/Physical](https://img.shields.io/badge/Environment-Hybrid_Physical-blue?style=for-the-badge)
![Host OS: Ubuntu](https://img.shields.io/badge/Host_OS-Ubuntu-orange?style=for-the-badge)

## 📖 Visão Geral
Este documento detalha a infraestrutura técnica utilizada para a execução dos testes de intrusão e simulações de Red Team. O laboratório foi projetado para ser **híbrido**, combinando virtualização avançada para servidores e dispositivos físicos reais (Android) para simulação de ataques a endpoints móveis.

---

## 🌐 1. Topologia de Rede (Network Architecture)

O laboratório opera em uma configuração de **Dual-Homing**, permitindo a gestão isolada entre o tráfego de auditoria e a conectividade de internet.

| Interface | Rede | Gateway | Função |
| :--- | :--- | :--- | :--- |
| **wlxc04...** | `192.168.100.0/24` | `192.168.100.1` | WAN (Acesso Externo / Updates) |
| **enp4s0** | `192.168.1.0/24` | `192.168.1.1` | **LAN (Auditoria / Bridge Mode)** |

---

## 🖥️ 2. Inventário de Ativos (Asset Inventory)

### A. Host & Privacy Layer
* **Host Principal (Ubuntu Linux):** Base de gestão e orquestração de virtualização.
* **Whonix Gateway & Workstation (VM):** Camada de anonimato para investigações em **Dark Web** e coleta de inteligência via rede Tor.

### B. Attack & Testing Nodes
* **Attack Box (Laptop - Lubuntu):** Estação ofensiva principal com suite de ferramentas de Pentest.
* **Web Target (Macbook 2008 - Debian 12):** Servidor Linux atualizado para testes de vulnerabilidades web (Apache/DVWA).
* **Workstation Target (VM - Windows 10):** Alvo para auditoria de protocolos Microsoft (SMB/RDP).

### C. Mobile Lab (Physical Devices)
Estes ativos permitem a prática de ataques via **ADB (Android Debug Bridge)**, análise de APKs maliciosos e interceptação de tráfego mobile.
* **Mobile 01 (Samsung J5 Prime):** Dispositivo Android físico para testes de persistência e bypass de biometria/PIN.
* **Mobile 02 (LG K8):** Dispositivo Android físico para análise de vulnerabilidades em versões legadas do sistema.

---

## 🛠️ 3. Configurações de Segurança e Isolamento
1.  **OpSec (Whonix):** Isolamento total da navegação Dark Web, prevenindo vazamentos de DNS e IP real do laboratório.
2.  **Network Bridge:** Todas as VMs e Dispositivos Físicos estão interconectados via interface `enp4s0`, garantindo que o tráfego de auditoria não interfira na rede Wi-Fi principal.
3.  **Physical Lab Integration:** Os dispositivos Android estão integrados via Wi-Fi ou USB Passthrough para auditoria de comunicações sem fio.

---

## 🚀 4. Fluxo de Operação
- **Reconhecimento:** Uso do script `ultra_recon_pro.py` para identificar IPs, MAC Vendors e TTL tanto das VMs quanto dos celulares físicos.
- **Auditoria Mobile:** Exploração de portas abertas (ex: porta 5555) e análise de tráfego via Burp Suite.
- **Exploração:** Pivotagem entre servidores Linux e endpoints Windows/Android.

---
**Responsável Técnico:** Zafire Daniel  
**Última Atualização:** Janeiro de 2026
