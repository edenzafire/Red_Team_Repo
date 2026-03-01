# Relatório Técnico de 07_Privilege_Escalation
## Alvo 03 – Metasploitable 2 (Linux Legado)
**Author:** Zafire Daniel  
**Data:** 2026-02-28  
**MITRE ATT&CK:** T1003.008 (Credential Dumping: /etc/passwd and /etc/shadow)  
**Status:** Concluído (ROOT Consolidado)  
**Ambiente:** Rede Interna (VLAN de Servidores Legados)  

---

# 1. Executive Summary
Este relatório documenta a consolidação do acesso de superusuário e a exfiltração de credenciais no Alvo 03. Dado que o vetor de entrada original já proveu uma shell com privilégios de **ROOT**, esta etapa focou na extração sistemática de segredos do sistema operacional e de aplicações (Bancos de Dados), visando a quebra de senhas offline e movimentação lateral.

---

# 2. Escopo
**Host alvo:**
* **Hostname:** METASPLOITABLE-02
* **IP:** 192.168.x.z
* **Usuário:** `root` (UID 0)
* **Objetivo:** Extração de hashes de sistema, chaves SSH e segredos de aplicações.

---

# 3. Metodologia (Enumeração de Segredos)
Com o acesso total garantido, a metodologia de pós-exploração seguiu:
1.  **System Dumping:** Leitura dos arquivos de autenticação do Linux.
2.  **SSH Harvesting:** Busca por chaves privadas e arquivos `known_hosts` para mapeamento de confiança.
3.  **Application Looting:** Extração de credenciais de bancos de dados MySQL e PostgreSQL presentes no host.

---

# 4. Timeline Técnica
* **00:00** – Verificação de integridade da shell ROOT via porta 6200.
* **00:10** – Extração completa dos arquivos `/etc/passwd` e `/etc/shadow`.
* **00:20** – Identificação e cópia de chaves SSH no diretório `/root/.ssh`.
* **00:40** – Dumping de hashes de usuários do MySQL.

---

# 5. Descobertas Técnicas

## 5.1 Consolidação e TTY Upgrade
Apesar de ser ROOT, a shell original era um "bind shell" básico. Foi executado o upgrade para uma shell interativa para facilitar a navegação nos diretórios sensíveis:
```bash
python -c 'import pty; pty.spawn("/bin/bash")'
```
### 5.2 Credential Dumping (Linux Hashes)

**Técnica MITRE:** [T1003.008 – /etc/passwd and /etc/shadow](https://attack.mitre.org/techniques/T1003/008/)

**Comando Executado:**
```bash
cat /etc/shadow
```
### 5.2.1 Análise Técnica (Dumping de Credenciais)
O arquivo `/etc/shadow` armazena os hashes das senhas criptografadas, sendo um recurso acessível exclusivamente pelo usuário **root**. Durante a coleta, foram extraídos hashes de múltiplos usuários (ex: `msfadmin`, `user`, `postgres`). Devido à arquitetura legada do sistema, muitos desses hashes utilizam algoritmos de derivação de chave obsoletos (como MD5-based crypt), tornando-os extremamente vulneráveis a ataques de força bruta acelerados por GPU. Utilizando ferramentas como **Hashcat** ou **John the Ripper**, a descoberta de senhas em texto claro torna-se possível em poucos minutos.

---

# 6. Pós-Exploração (Loot & Movimentação Lateral)

Com o controle total do host, foram realizadas as seguintes ações estratégicas de exfiltração:

* **SSH Keys:** Identificação e captura de chaves privadas (`id_rsa`) no diretório do root. Estas chaves permitem o acesso direto a outros servidores da infraestrutura que compartilham a mesma relação de confiança, eliminando a necessidade de novas explorações e garantindo persistência silenciosa.
* **Database Loot:** Extração de tabelas de autenticação do banco de dados **MySQL**. A recuperação dessas credenciais é crítica, pois possibilita ataques de **Password Reuse** (reutilização de senha) em outros serviços corporativos e portais administrativos.
* **Network Mapping:** Utilização do comando `netstat -ano` para mapear conexões ativas e serviços internos, permitindo identificar o **Alvo 04** (Domain Controller) e outros ativos ocultos que não eram visíveis a partir do perímetro externo.

---

# 7. Avaliação de Risco

* **Classificação:** Crítico  
* **Impacto:** Exposição total e irrestrita de credenciais do sistema operacional, segredos de aplicações e chaves de acesso de terceiros.
* **Complexidade:** Nula (Uma vez que o acesso ROOT já foi estabelecido na fase de exploração).

---

# 8. Mitigações Recomendadas

* **Decommissioning:** Servidores vulneráveis por design, como o Metasploitable 2, **jamais** devem coexistir em redes de produção ou segmentos conectados a ativos críticos. Recomenda-se o desligamento e substituição imediata por versões modernas e seguras.
* **Password Policy:** Implementar políticas rigorosas de rotação de senhas e exigir que chaves SSH sejam obrigatoriamente protegidas por *passphrases* robustas, impedindo o uso imediato das chaves em caso de exfiltração física do arquivo.

---

# 9. Defesa (Blue Team Perspective)

**Indicadores de Comprometimento (IoCs):**
* **Acesso a Arquivos Sensíveis:** Monitoramento de acessos em massa ou leitura de arquivos no diretório `/etc/` (shadow/passwd) ou diretórios ocultos de chaves SSH (`.ssh/`).
* **Abuso de Ferramentas:** Alertas para a execução de utilitários de dumping de banco de dados (ex: `mysqldump`) por usuários ou processos que não fazem parte da rotina de backup oficial.

---

# 10. Apêndice – Evidências

**Evidence 01:** Captura do arquivo `/etc/shadow` exibindo os hashes dos usuários do sistema prontos para cracking.  
**Evidence 02:** Listagem detalhada do diretório `/root/.ssh/`, comprovando a existência, leitura e captura bem-sucedida de chaves privadas exfiltradas.

---

# 11. Conclusão

O Alvo 03 demonstrou ser um ponto central de falha e uma fonte inesgotável de inteligência técnica. A ausência de defesas pós-exploração permitiu uma coleta de dados agressiva. Os resultados obtidos — hashes, senhas e chaves SSH — são ativos fundamentais que servirão como o armamento final para a progressão e comprometimento total do **Alvo 04 (Active Directory)**.
