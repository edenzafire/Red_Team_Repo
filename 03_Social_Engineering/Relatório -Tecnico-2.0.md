# 🚩 Technical Report: Operation "Luthieria Flamenca v2.0"

**Security Researcher:** Nikolay (Zafire Daniel)

**Target:** Windows 10 x64 (Build 19045)

**Threat Actor Profile:** Specialized Social Engineering & Custom Tooling

**Verdict:** **[POC SUCCESSFUL]** - EDR/AV Bypass achieved via In-Memory Decryption.

---

## 0x01. Executive Overview

Este relatório documenta a evolução de uma cadeia de infecção de múltiplos estágios. A operação contorna soluções de segurança perimetral (Proxies/Firewalls) através de **HTML Smuggling** e neutraliza detecções estáticas de endpoint (Windows Defender) via **Polimorfismo Estático (XOR)** e **Custom Droppers** escritos em C++.

## 0x02. The Infection Chain (Flow Analysis)

Diferente de ataques genéricos, esta cadeia foi desenhada para ser silenciosa:

1. **Delivery:** O alvo acessa uma página HTML legítima. Um script JS reconstrói um objeto `Blob` em memória.
    
2. **Container:** O usuário extrai um arquivo `.ISO` (contornando filtros de anexo de e-mail).
    
3. **Execution:** O usuário executa um binário disfarçado.
    
4. **Decapsulation:** O dropper (C++) aloca memória, descriptografa o shellcode XORed e o executa via `CreateThread`.
    

---

## 0x03. Adversary Tactics & Techniques (MITRE ATT&CK)

### 3.1 Defense Evasion: Obfuscated Files ([T1027](https://attack.mitre.org/techniques/T1027/))

O payload (`msfvenom` raw) foi submetido a uma transformação simétrica simples, porém eficaz contra assinaturas:

- **Algorithm:** `XOR` with `0x77` key.
    
- **Implementation:** Um script Python processa o binário e gera um `const unsigned char payload[]` para o código-fonte C++.
    

### 3.2 Delivery: HTML Smuggling ([T1027.006](https://attack.mitre.org/techniques/T1027/006/))

Utilizamos o navegador do alvo para "montar" o artefato malicioso localmente.

- **Mechanism:** `window.URL.createObjectURL(blob)`.
    
- **Bypass:** Como o arquivo `.ISO` nasce dentro do browser, ele não atravessa o gateway de rede como um executável, evadindo assinaturas de tráfego (IDS/IPS).
    

### 3.3 User Execution: Malicious File ([T1204.002](https://attack.mitre.org/techniques/T1204/002/))

Exploração da psicologia do usuário através de **Masquerading**. O contêiner ISO contém um "arquivo duplo" onde o `.exe` utiliza um ícone de PDF (Resource ID 101) e o nome do arquivo isca.

---

## 0x04. The "Forge": Low-Level Details

### Dropper Construction (C++)

O código foi compilado para evitar dependências de runtime (Static Linking):

Bash

```
# Cross-compilation command (Debian to Windows)
x86_64-w64-mingw32-g++ main.cpp resource.res -o Medidas_Paco_De_Lucia.exe \
    -mwindows -static-libgcc -static-libstdc++ -Wl,-subsystem,windows
```

- **Anti-Analysis:** O uso da flag `-mwindows` impede a criação de uma janela de console (Subsystem: Windows GUI), tornando a execução invisível ao olho humano.
    
- **Memory Allocation:** O dropper utiliza `VirtualAlloc` com permissões `PAGE_EXECUTE_READWRITE` (0x40) para hospedar o shellcode descriptografado.
    

---

## 0x05. Operation Timeline (Red Team Ops)

|**Epoch (UTC)**|**Phase**|**MITRE ID**|**Result**|
|---|---|---|---|
|**T+00h**|Recon|[T1594](https://attack.mitre.org/techniques/T1594/)|Identified Luthieria interest (Luthier/Conde).|
|**T+01h**|Weaponization|[T1027](https://attack.mitre.org/techniques/T1027/)|C++/XOR Dropper compiled (FUD).|
|**T+02h**|Delivery|[T1027.006](https://attack.mitre.org/techniques/T1027/006/)|HTML Smuggling portal live.|
|**T+03h**|Execution|[T1204.002](https://attack.mitre.org/techniques/T1204/002/)|**Waiting for user interaction (Social Engineering).**|

---

## 0x06. Countermeasures (Blue Team Perspective)

Para mitigar esta ameaça, a defesa deve focar em **Comportamento** e não em **Assinatura**:

- **ASR Rules:** Ativar "Block all Office applications from creating child processes".
    
- **EDR Detection:** Monitorar a API `VirtualAlloc` seguida imediatamente por `CreateThread` em processos não assinados (Unsigned Binaries).
    
- **GPO:** Desabilitar a associação de arquivos para imagens de disco (`.iso`, `.vhd`) para usuários comuns.
    

---

**Researcher's Note:** _This laboratory proves that even simple symmetric encryption (XOR) combined with non-traditional delivery methods (ISO/Smuggling) is sufficient to bypass current top-tier Endpoint Protection (EPP) solutions._
---
