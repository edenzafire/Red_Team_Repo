# 🚩Operação "Paco de Lucía" - Ataque de Spear Phishing

**Alvo:** Host Windows 10 (Build 19045) **Nível:** Médio/Realista **Status:** **Mitigado (Veredito: Vitória Defensiva)**

---

## 1. 🎯 Vetor de Entrada (Initial Access)

O ataque foi planejado utilizando **Engenharia Social** focada em um interesse específico do alvo (Luteria/Violão Flamenco).

- **Arquivo Isca:** `projeto-original.pdf`
    
- **Payload:** Script PowerShell (`luthier_script.ps1`) via `msfvenom`.
    
- **Disfarce (Obfuscation):** Utilização do caractere Unicode **RTLO** (Right-to-Left Override) para inverter a extensão de `.vbs` para `.pdf`.
    
    - _Nome real:_ `Medidas_Paco_De_Lucia_vbs.fdp` (visualizado como `.pdf`).
        

## 2. 🎣 A Armadilha (Delivery)

Foi configurado um servidor HTTP via Python (`python3 -m http.server 80`) para hospedar o pacote `Medidas_Tecnicas_Hermanos_Conde_1971.zip`.

> **Log do Atacante:** `192.168.1.112 - - [05/Mar/2026] "GET /Medidas_...zip HTTP/1.1" 200 -`

## 3. 🛡️ O Confronto: Atacante vs Defender

Ao realizar o download e a extração no host alvo, o sistema de proteção entrou em ação.

### **Cronologia da Detecção:**

1. **Extração:** O usuário extraiu o conteúdo do arquivo `.zip`.
    
2. **Escaneamento em Tempo Real:** O Windows Defender detectou a assinatura estática do arquivo `luthier_script.ps1`.
    
3. **Veredito do Antivírus:** Detecção de `Trojan:PowerShell/Meterpreter.A`.
    
4. **Ação Automática:** O arquivo foi movido para quarentena e a execução do script VBS falhou ao tentar localizar o componente PowerShell removido.
    

## 4. 📝 Análise Pós-Incidente (A Derrota Vitoriosa)

**Por que falhou?**

- **Assinatura estática:** O payload do Metasploit (`psh-reflection`) é amplamente conhecido. Sem um _encoder_ customizado ou técnica de _AMSI Bypass_, a detecção é de 99%.
    
- **Vigilância do Usuário:** O Windows Chrome alertou sobre "Download Inseguro", exigindo que o usuário forçasse o recebimento.
    

**O que aprendemos?**

- A engenharia social (o e-mail e o nome do arquivo) funcionou 100%, pois o alvo baixou e tentou abrir.
    
- A camada de **Endpoint Protection (EDR)** cumpriu seu papel, provando que a defesa em profundidade funciona.
    

---

## 5. 🛠️ Recomendações (Remediação)

- **Para o Atacante (Próximo Lab):** Utilizar técnicas de **SFX** para comprimir tudo em um executável com ícone de PDF e aplicar ofuscação de código (base64) para tentar evadir o Defender.
    
- **Para a Defesa:** Manter o Windows Defender atualizado e bloquear a execução de scripts `.vbs` e `.ps1` por usuários comuns via GPO.