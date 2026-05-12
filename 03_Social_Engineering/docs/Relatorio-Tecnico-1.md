# 🚩 Technical Report: Operation "Paco de Lucía"

**Security Researcher:** Nikolay (Zafire Daniel)

**Target:** Windows 10 x64 (Build 19045)

**Threat Actor Profile:** Social Engineering & RTLO Masquerading

**Verdict:** **[MITIGATED]** - Endpoint Security (AV/EDR) Blocked Execution.

---

## 0x01. Executive Overview

Este relatório detalha uma tentativa de **Spear Phishing** baseada em scripts. A operação visava testar a eficácia da técnica de **RTLO (Right-to-Left Override)** contra a percepção do usuário e a resposta do **Windows Defender** a _payloads_ gerados via Metasploit. Embora o vetor de entrega tenha sido bem-sucedido, a detecção baseada em assinaturas impediu o comprometimento do host.

## 0x02. Initial Access & Masquerading

O ataque explorou um interesse específico do alvo (**Luteria Flamenca**) para facilitar a execução de arquivos não confiáveis.

### 2.1 The RTLO Trick ([T1036.002](https://attack.mitre.org/techniques/T1036/002/))

Para ocultar a natureza real do script malicioso, foi utilizado o caractere Unicode `U+202E`.

- **Filename on disk:** `Medidas_Paco_De_Lucia_vbs.fdp`
    
- **User UI Display:** `Medidas_Paco_De_Lucia_pdf.vbs`
    
- **Analysis:** Esta técnica explora a falha humana na interpretação de extensões, mas é irrelevante para o kernel do Windows, que identifica o arquivo pelo seu _Magic Header_ e extensão real.
    

---

## 0x03. Adversary Tactics & Techniques (MITRE ATT&CK)

|**Tática**|**Técnica**|**ID**|**Link**|
|---|---|---|---|
|**Initial Access**|Spearphishing Link|T1566.002|[Link](https://attack.mitre.org/techniques/T1566/002/)|
|**Defense Evasion**|Masquerading: RTLO|T1036.002|[Link](https://attack.mitre.org/techniques/T1036/002/)|
|**Execution**|PowerShell Interpreter|T1059.001|[Link](https://attack.mitre.org/techniques/T1059/001/)|

---

## 0x04. Execution Flow & Detection Analysis

### 4.1 Delivery Infrastructure

Utilizou-se um servidor efêmero para hospedagem do artefato:

`python3 -m http.server 80` -> `192.168.1.112`

### 4.2 The "AMSI" Barrier

O payload utilizado foi um script PowerShell (`psh-reflection`).

- **Behavior:** No momento em que o script VBS tentou invocar o PowerShell para carregar o código em memória, o **AMSI (Antimalware Scan Interface)** interceptou o buffer.
    
- **Detection:** O Windows Defender identificou a assinatura `Trojan:PowerShell/Meterpreter.A`.
    
- **Outcome:** Interrupção imediata do processo. Como o _payload_ era "puro" (sem ofuscação), a entropia do arquivo era baixa, facilitando a análise estática do AV.
    

---

## 0x05. Operation Timeline

|**Time (UTC)**|**Action**|**Method**|**Result**|
|---|---|---|---|
|**14:00**|Recon|OSINT|Identified interest in "Conde/Paco de Lucía".|
|**14:30**|Weaponization|MSFVenom|Generated standard PSH-Reflection payload.|
|**15:00**|Delivery|HTTP Server|User initiated download via Chrome.|
|**15:05**|Execution|User Action|**Blocked by Windows Defender (Signature Match).**|

---

## 0x06. Post-Mortem & Mitigation

### Why it failed?

1. **Static Signatures:** O uso de ferramentas _out-of-the-box_ (Metasploit) sem modificação de bytes é trivialmente detectado por qualquer solução de segurança moderna.
    
2. **Reputation Check:** O Google Chrome utilizou o _Safe Browsing_ para alertar o usuário sobre o download de um domínio sem reputação prévia.
    

### Blue Team Recommendations

- **GPO (Group Policy):** Desabilitar o interpretador `Windows Script Host` para bloquear arquivos `.vbs` e `.js` nativamente.
    
- **Attack Surface Reduction (ASR):** Ativar a regra de bloqueio para que o Adobe Reader ou navegadores não possam lançar processos filhos como `powershell.exe`.
    

---

**Researcher's Note:** _Esta operação serviu como Baseline para a V2.0. A principal lição é que o RTLO engana o humano, mas não engana o AMSI. Para sucesso futuro, a ofuscação de baixo nível (XOR/C++) é mandatória._