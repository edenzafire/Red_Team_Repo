# Relatório Técnico: Operação "Luthieria Flamenca v2.0"
**Status:** 🔴 Exploração de Alta Complexidade (PoC)  
**Classificação:** Crítico (CVSS 9.8)  
**Técnicas:** HTML Smuggling + Ofuscação XOR + ISO Dropper  
**Autor:** Nikolay (Zafire Daniel)  
**Data:** 2026-03-20

---

## 1. Resumo Executivo
Esta operação evoluiu de um simples phishing para uma cadeia de ataque multi-estágio. Foi simulado um portal de downloads legítimo (**Hermanos Conde**) utilizando a técnica de **HTML Smuggling** para contornar inspeções de tráfego de rede. O payload foi protegido por criptografia simétrica (XOR) e embutido em um contêiner de disco (ISO), visando a evasão de soluções de EDR e Antivírus (Windows Defender).

## 2. Escopo e Ambiente
* **Host Alvo:** Windows 10 (Totalmente atualizado / Defender Ativo).
* **Atacante:** Debian Linux (Ambiente de desenvolvimento C++ e Cross-Compilation).
* **Vetor de Entrega:** Smuggling via JavaScript (Blob Download).

## 3. Metodologia (MITRE ATT&CK)

### 3.1 Ofuscação e Evasão (T1027)
Diferente da versão anterior, o shellcode não foi entregue em texto puro.
* **Criptografia XOR:** O payload foi encriptado com uma chave de 8 bits (`0x77`) via Python para quebrar a assinatura estática do Metasploit.
* **Desenvolvimento C++:** Criado um *dropper* customizado em C++ que realiza a descriptografia apenas em tempo de execução na memória RAM (**In-Memory Decryption**).

### 3.2 Entrega via HTML Smuggling (T1027.006)
Utilizou-se um script JavaScript para reconstruir um arquivo **ISO** bit-a-bit no navegador do alvo a partir de uma string Base64.
* **Vantagem:** O tráfego de rede é interpretado como texto legítimo, evadindo proxies que bloqueiam downloads de executáveis diretos.

### 3.3 Engenharia Social de Arquivo Duplo (T1204.002)
O arquivo entregue foi um `.ISO` (imagem de disco) contendo:
1. `Medidas_Paco_De_Lucia_Oficial_1971.pdf` (Isca real/Decoy).
2. `Medidas_Paco_De_Lucia_Oficial_1971.exe` (Payload disfarçado com ícone de PDF e nome idêntico).



---

## 4. Detalhamento da "Forja" Técnica

### Passos de Construção:
1. **Shellcode:** Gerado via `msfvenom` em formato raw.
2. **Criptografia:** Execução do script `encrypt.py` para gerar o array de bytes ofuscado.
3. **Compilação:** Uso do `x86_64-w64-mingw32-g++` no Debian com as flags `-mwindows` (ocultar console) e inclusão de arquivo de recurso `.res` para o ícone.
4. **Empacotamento:** Criação da imagem ISO com `genisoimage` usando a flag `-V` para nomear o volume.

## 5. Cronograma da Operação Atualizada

| Hora  | Ação           | Técnica             | Resultado                                   |
| :---- | :------------- | :------------------ | :------------------------------------------ |
| 10:00 | Reconhecimento | OSINT (Luthieria)   | Definição da temática "Conde".              |
| 11:30 | Armamento      | C++ + XOR           | Binário indetectável (FUD) gerado.          |
| 12:00 | Preparação     | HTML Smuggling      | Portal Hermanos Conde (HTML) configurado.   |
| --:-- | Execução       | Eng. Social         | **Aguardando interação do alvo.** |

---

## 6. Mitigações Recomendadas (Blue Team)
1. **Bloqueio de Extensões:** Impedir a montagem automática de arquivos `.ISO`, `.IMG` e `.VHD` por usuários comuns via GPO.
2. **Monitoramento de Processos:** Implementar regras de detecção para processos (como o nosso `.exe`) que chamam APIs suspeitas como `VirtualAllocEx` e `CreateThread` em sequência.
3. **Inspeção de JavaScript:** Utilizar soluções de segurança de e-mail e web que identifiquem o uso de `msSaveOrOpenBlob` ou reconstrução de arquivos via Base64 em páginas não confiáveis.

---
**Notas Adicionais:**
*O sucesso desta PoC demonstra que a confiança do usuário em materiais técnicos específicos (Luthieria) é o vetor mais crítico de entrada em redes corporativas.*

### Evidência 02: Screenshot Remota
*(Inserir imagem capturada com o comando `screenshot` aqui)*

---
