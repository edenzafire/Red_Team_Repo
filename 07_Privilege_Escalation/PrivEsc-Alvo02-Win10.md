
# Relatório Técnico de 07_Privilege_Escalation
## Alvo 02 – Windows 10 Pro (Workstation)
**Author:** Zafire Daniel  
**Data:** 2026-02-28  
**MITRE ATT&CK:** T1003.001 (OS Credential Dumping: LSA Secrets)  
**Status:** Concluído (SYSTEM Access)  
**Ambiente:** Rede Interna (Acessado via Pivot Alvo 01)  

---

# 1. Executive Summary
Este relatório documenta a consolidação de privilégios e a extração de credenciais no Alvo 02. Após o acesso inicial via SMB Relay, a operação focou em elevar o privilégio de Administrador Local para **NT AUTHORITY\SYSTEM** e realizar o dumping de segredos da memória e do registro, visando a obtenção de hashes de usuários do domínio.

---

# 2. Escopo
**Host alvo:**
* **Hostname:** WIN10-PRO-WS
* **IP:** 192.168.x.w
* **Usuário Inicial:** `AdminLocal` (via Relay)
* **Objetivo:** Obter privilégios de `SYSTEM` e capturar hashes NTLM/Kerberos.

---

# 3. Metodologia (Enumeração e Coleta)
A elevação e coleta seguiram estas etapas:
1.  **Verificação de Privilégios:** Uso do comando `whoami /priv` para identificar tokens de personificação.
2.  **Dumping de Memória:** Uso do `Mimikatz` ou `lsassy` para interagir com o processo LSASS.
3.  **Extração de Hive:** Cópia das colmeias `SAM`, `SYSTEM` e `SECURITY` para extração offline.
4.  **Enumeração de Sessões:** Identificação de usuários de domínio logados na máquina.

---

# 4. Timeline Técnica
* **00:00** – Consolidação da shell administrativa via `Evil-WinRM`.
* **00:10** – Execução do `WinPEAS.exe` para busca de vetores de escalada adicionais.
* **00:25** – Bypass de AMSI para execução de scripts de coleta em memória.
* **00:35** – Dumping bem-sucedido do LSASS e extração de hashes NTLM.

---

# 5. Descobertas Técnicas

## 5.1 Elevação para SYSTEM (Token Impersonation)
**Técnica MITRE:** [T1134.001 – Token Impersonation/Theft](https://attack.mitre.org/techniques/T1134/001/)

**Comando Executado:**
```powershell
# Utilizando o módulo Incognito no Metasploit ou ferramentas similares
impersonate_token "NT AUTHORITY\SYSTEM"
```
### 5.1.1 Análise Técnica (Privilege Escalation)
Como o acesso inicial foi obtido com privilégios administrativos, o processo do atacante detém o privilégio `SeDebugPrivilege`. Esta permissão de baixo nível permite que a shell interaja diretamente com qualquer outro processo em execução no sistema. Através da técnica de **Token Impersonation**, foi possível personificar o token de segurança do processo `SYSTEM`, elevando o nível de controle ao patamar máximo permitido pela arquitetura Windows.

---

## 5.2 Credential Dumping (LSASS)

**Payload Utilizado (Mimikatz):**
```bash
privilege::debug
sekurlsa::logonpasswords
```

### 5.2.1 Análise Técnica (Dumping de Memória)
O processo `lsass.exe` (*Local Security Authority Subsystem Service*) é o componente crítico do Windows responsável por gerenciar as políticas de segurança e armazenar credenciais em cache para usuários logados. Ao realizar o *debug* deste processo em memória, é possível extrair segredos como **hashes NTLM** e **tickets Kerberos**. No cenário deste laboratório, foram exfiltrados hashes de um usuário de domínio que realizou login anteriormente na máquina, viabilizando ataques de **Pass-the-Hash** contra o Alvo 04 (Domain Controller).



---

# 6. Pós-Exploração (Loot & Preparação para AD)

Com os privilégios de `SYSTEM` consolidados, as seguintes ações foram executadas:

* **Loot:** Captura do hash NTLM do usuário `suporte_ti`, identificado como membro de grupos privilegiados no domínio.
* **Mapeamento:** Execução do `SharpHound.exe` via memória (fileless) para coletar a estrutura completa do Active Directory (usuários, grupos, GPOs e ACLs) a partir desta estação comprometida.
* **Persistência:** Implementação de um serviço oculto ou modificação de uma tarefa agendada existente para garantir o retorno do acesso caso a sessão atual seja encerrada ou o sistema seja reiniciado.

---

# 7. Avaliação de Risco

* **Classificação:** Crítico  
* **Impacto:** Exposição de credenciais de alto privilégio do domínio e comprometimento total da integridade e confidencialidade da estação de trabalho.  
* **Complexidade:** Média (O sucesso depende do bypass de defesas locais como Windows Defender ou soluções de EDR).

---

# 8. Mitigações Recomendadas

* **LSA Protection:** Habilitar a proteção adicional (`RunAsPPL`) para o processo LSASS, impedindo a leitura de sua memória por processos não autorizados.
* **Restrictive Admin:** Implementar políticas de restrição de login (GPO), impedindo que contas administrativas de domínio se autentiquem em estações de trabalho comuns.
* **Credential Guard:** Utilizar o isolamento baseado em virtualização (VBS) para proteger segredos e hashes contra extração em memória.

---

# 9. Defesa (Blue Team Perspective)

**Indicadores de Comprometimento (IoCs):**
* **Event ID 4663:** Monitoramento de acesso suspeito ou não autorizado ao processo `lsass.exe` (especialmente se originado por processos não confiáveis).
* **Event ID 4697:** Registro de instalação de novos serviços (comportamento típico de ferramentas como `psexec`, `smbexec` ou persistências maliciosas).
* **AMSI Logs:** Alertas gerados pela interface de monitoramento de antimalware indicando tentativas de bypass ou execução de scripts PowerShell ofuscados.

---

# 10. Apêndice – Evidências

**Evidence 01:** Saída do comando `sekurlsa::logonpasswords` do Mimikatz exibindo claramente o hash NTLM do usuário de domínio.  
**Evidence 02:** Captura do comando `whoami` confirmando o contexto de execução como `NT AUTHORITY\SYSTEM`.

---

# 11. Conclusão

A escalada e coleta no Alvo 02 transformaram um acesso local em uma vantagem estratégica decisiva para o ataque ao domínio. Com os hashes capturados e o mapeamento do AD realizado via SharpHound, o caminho para o **Domain Controller** está tecnicamente aberto através de técnicas como **Pass-the-Hash** ou **Kerberoasting**.