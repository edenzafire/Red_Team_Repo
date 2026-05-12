# 🚩 Relatório Técnico: Operação Luthieria Flamenca v2.0

**Pesquisador:** Nikolay (Zafire Daniel)

**Data:** 11 de Maio de 2026

**Alvo:** Windows 10 x64 (Build 19045)

**Status:** Fase 03_Social_Enginering (Concluída)

**Veredito:** **[POC BEM-SUCEDIDO]** - Bypass de EDR/AV obtido por meio de descriptografia em memória.

---

## 0x01. Introdução e Vetor de Ataque

Este relatório documenta a evolução de uma cadeia de desenvolvimento de múltiplos estágios. A operação contorna soluções de segurança perimetral (Proxies/Firewalls) através de **HTML Smuggling** e neutraliza detecções estáticas de endpoint (Windows Defender) via **Polimorfismo Estático (XOR)** e **Custom Droppers** escritos em C++. O ataque utiliza um pretexto de engenharia social focado em nichos técnicos (Luthieria) para induzir a execução de um artefato customizado.

### Componentes da Cadeia de Ataque:

- **Entrega:** O alvo acesse uma página HTML legítima. Um script JS reconstrói um objeto `Blob`na memória.
- 
- **Ofuscação:** Payload XOR (Chave 0x77) embutido em código C++.
    
- **Contêiner:** Imagem ISO para evasão de Mark-of-the-Web (MotW).
    
  **Decapsulamento:** O dropper (C++) aloca memória, descritivo do shellcode XORed 
  e o executado via CreateThread.
      
- **Carga Útil:** Shell reversa Meterpreter x64 (Staged).
    

---

## 0x02. Anatomia do Phishing e Smuggling

A fase de entrega não utiliza anexos diretos, o que evita filtros de gateway de e-mail comuns.

### Mecânica de HTML Smuggling:

O arquivo `phishing.html` contém o binário da ISO convertido em uma string **Base64** gigante. Ao ser acessado, o JavaScript reconstrói o arquivo localmente no navegador do alvo.

> **Figura 1:** _Exibição do diretório de arquivos no servidor atacante (IP: 192.168.1.143). O arquivo `phishing.html` atua como o dropper de primeiro estágio._
 ![https://github.com/edenzafire/Red_Team_Repo/blob/main/03_Social_Engineering/evidence/02_Relatorio/AnatomiaDoPhishing.png]

### O Contêiner ISO:

Dentro da ISO, o artefato `Medidas_Paco_De_Lucia_Oficial_1971.exe` utiliza um ícone de PDF para mascarar sua verdadeira natureza. O uso da ISO é estratégico: o Windows monta o arquivo como uma unidade virtual, e muitos sistemas de segurança não escaneiam o conteúdo de drives montados com o mesmo rigor que arquivos baixados.

---

## 0x03. Táticas e Técnicas do Adversário (MITRE ATT&CK)

[](https://github.com/edenzafire/Red_Team_Repo/blob/main/03_Social_Engineering/Relat%C3%B3rio%20-Tecnico-2.0.md#0x03-adversary-tactics--techniques-mitre-attck)

### 3.1 Evasão de Defesa: Arquivos Ofuscados ( [T1027](https://attack.mitre.org/techniques/T1027/) )

[](https://github.com/edenzafire/Red_Team_Repo/blob/main/03_Social_Engineering/Relat%C3%B3rio%20-Tecnico-2.0.md#31-defense-evasion-obfuscated-files-t1027)

O payload ( `msfvenom`raw) foi submetido a uma transformação simétrica simples, porém eficaz contra assinaturas:

- **Algoritmo:** `XOR` com `0x77`chave.
    
- **Implementação:** Um script Python processa o binário e gera um `const unsigned char payload[]`código-fonte C++.
    

### 3.2 Entrega: Contrabando de HTML ( [T1027.006](https://attack.mitre.org/techniques/T1027/006/) )

[](https://github.com/edenzafire/Red_Team_Repo/blob/main/03_Social_Engineering/Relat%C3%B3rio%20-Tecnico-2.0.md#32-delivery-html-smuggling-t1027006)

Utilizamos o navegador do alvo para "montar" o tráfego fraudulento localmente.

- **Mecanismo:** `window.URL.createObjectURL(blob)` .
    
- **Bypass:** Como o arquivo `.ISO`nasce dentro do navegador, ele não atravessa o gateway de rede como um devedor, evitando assinaturas de tráfego (IDS/IPS).
    

### 3.3 Execução do usuário: Arquivo malicioso ( [T1204.002](https://attack.mitre.org/techniques/T1204/002/) )

[](https://github.com/edenzafire/Red_Team_Repo/blob/main/03_Social_Engineering/Relat%C3%B3rio%20-Tecnico-2.0.md#33-user-execution-malicious-file-t1204002)

Exploração da psicologia do usuário através do **Mascaramento** . O contêiner ISO contém um "arquivo duplo" onde o `.exe`utiliza um ícone de PDF (Resource ID 101) e o nome do arquivo isca.

---

## 0x03.1. Desenvolvimento do Artefato (Dropper C++)

O binário foi desenvolvido em C++ para garantir baixa taxa de detecção. O shellcode gerado pelo `msfvenom` foi ofuscado com uma operação XOR simples para quebrar assinaturas estáticas do Windows Defender.

C++

```
// Trecho lógico do decapsulador
for (int i = 0; i < sizeof(payload); i++) {
    payload[i] = payload[i] ^ 0x77; // Descriptografia em tempo de execução
}
VirtualAlloc(... PAGE_EXECUTE_READWRITE); // Alocação de memória
CreateThread(...); // Execução da Shellcode
```


### Construção do Dropper (C++)

[](https://github.com/edenzafire/Red_Team_Repo/blob/main/03_Social_Engineering/Relat%C3%B3rio%20-Tecnico-2.0.md#dropper-construction-c)

O código foi compilado para evitar dependências de tempo de execução (Static Linking):

Bash

```
# Cross-compilation command (Debian to Windows)
x86_64-w64-mingw32-g++ main.cpp resource.res -o Medidas_Paco_De_Lucia.exe \
    -mwindows -static-libgcc -static-libstdc++ -Wl,-subsystem,windows
```

- **Anti-Análise:** O uso da flag `-mwindows`impede a criação de uma janela de console (Subsistema: Windows GUI), tornando a execução invisível ao olho humano.
    
- **Alocação de memória:** O dropper utiliza `VirtualAlloc`com permissões `PAGE_EXECUTE_READWRITE`(0x40) para hospedar o shellcode descrito.
---

## 0x04. Exploração e Ganho de Acesso

O "ouvinte" (Handler) no Metasploit foi configurado para aguardar a conexão na porta 4444.

> **Figura 2:** _Momento da captura: O alvo executa o binário dentro da ISO, disparando o envio do 'Stage' (248KB) e abrindo a sessão Meterpreter._ ![Inserir 571a8867-10ba-4aaf-b4ec-8f79e8769c85 aqui]

---

## 0x05. Pós-Exploração: Persistência Manual

Uma vez dentro do sistema, o foco foi garantir a permanência no host (Persistence), mesmo após reinicializações.

### Tática MITRE ATT&CK: T1547.001 (Run Keys)

Utilizamos o prompt de comando do Windows (`cmd`) através do Meterpreter para realizar as seguintes ações:

1. **Migração do Artefato:** O arquivo foi copiado para a pasta oculta `%APPDATA%` e renomeado para `WindowsUpdater.exe`.
    
2. **Modificação do Registro:** Criada uma chave de execução automática no registro do usuário.
    

DOS

```
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "SecurityUpdate" /t REG_SZ /d "%APPDATA%\WindowsUpdater.exe" /f
```

> **Figura 3:** _Comandos executados via shell remota confirmando a criação da chave de persistência e a localização do novo binário oculto._ ![Inserir Persistence.jpg aqui]

---

## 0x06. Desafios e Próximos Passos

Durante o processo, o comando `getsystem` falhou, indicando a presença de proteção **UAC (User Account Control)** ativa no host. Isso impede que o atacante tenha controle total sobre processos críticos do sistema.

### Objetivos para o Módulo 04_Enumeration:

- [ ] **Bypass UAC:** Utilizar o módulo `fodhelper` para elevar privilégios para Administrador.
    
- [ ] **Enumeração de Rede:** Identificar outros hosts na subrede 192.168.1.0/24.
    
- [ ] **Dump de Credenciais:** Extrair hashes de senhas do banco SAM/LSASS.
