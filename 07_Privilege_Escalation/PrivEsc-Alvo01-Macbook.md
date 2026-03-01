
# Relatório Técnico de 07_Privilege_Escalation
## Alvo 01 – Apache / DVWA (Macbook 2008)
**Author:** Zafire Daniel  
**Data:** 2026-02-28  
**MITRE ATT&CK:** T1548.003 (Abuse Elevation Control Mechanism: Sudo)  
**Status:** Concluído (ROOT Access)  
**Ambiente:** Laboratório Controlado  

---

# 1. Executive Summary
Este relatório documenta a elevação de privilégios no Alvo 01, partindo do usuário de serviço `www-data` para o superusuário `root`. A escalada foi possível devido a uma configuração permissiva no arquivo `/etc/sudoers`, permitindo a execução de um binário de sistema sem a necessidade de senha.

---

# 2. Escopo
**Host alvo:**
* **Hostname:** MAC-DEBIAN-SRV
* **IP:** 192.168.x.y
* **Usuário Inicial:** `www-data` (UID 33)
* **Objetivo:** Obter privilégios de `root` (UID 0).

---

# 3. Metodologia (Enumeração Local)
A fase de enumeração utilizou scripts automatizados e verificação manual:
1.  **Enumeração Automatizada:** Execução do `LinPEAS.sh` para identificar vetores de kernel e permissões.
2.  **Verificação de Sudo:** Execução do comando `sudo -l` para listar privilégios permitidos.
3.  **Busca de SUID:** Localização de arquivos com o bit *Set Owner User ID* ativo.

---

# 4. Timeline Técnica
* **00:00** – Início da enumeração local com `LinPEAS`.
* **00:05** – Identificação de permissão de `sudo` para o binário `/usr/bin/find`.
* **00:08** – Pesquisa no **GTFOBins** para técnica de escape de privilégios.
* **00:10** – Execução do exploit de configuração e obtenção de shell `root`.

---

# 5. Descobertas Técnicas

## 5.1 Identificação do Vetor (Sudo -l)
**Comando Executado:**
```bash
sudo -l
```

**Resultado:**
O sistema retornou que o usuário `www-data` possui uma permissão altamente permissiva no arquivo `/etc/sudoers`, permitindo executar o seguinte binário com privilégios de superusuário sem fornecer credenciais:
> `(root) NOPASSWD: /usr/bin/find`

---

### 5.2 Exploração – Abuso do Binário Find

**Técnica MITRE:** [T1548.003 – Sudo and Sudo Caching](https://attack.mitre.org/techniques/T1548/003/)

**Payload Utilizado:**
```bash
sudo find . -exec /bin/sh -p \; -quit
```

### 5.2.1 Análise Técnica
O binário `find` possui a flag `-exec`, projetada para processar comandos sobre os resultados de uma busca. Ao invocar `sudo find`, o binário é executado no espaço de memória do usuário **root**. O comando subsequente `/bin/sh -p` cria um novo processo de shell que herda o **UID 0**. A flag `-p` (*privileged*) é crucial neste cenário para evitar que a shell descarte os privilégios efetivos durante a inicialização, garantindo o acesso total ao sistema.

---

# 6. Pós-Exploração (Loot & Persistência)

Com o acesso **ROOT** consolidado, as seguintes ações de pós-exploração foram executadas para garantir a continuidade da operação:

* **Leitura de Segredos:** Extração do arquivo `/etc/shadow`. Este arquivo contém os hashes das senhas de todos os usuários do sistema, permitindo ataques de força bruta offline (*Cracking*) para descoberta de credenciais administrativas.
* **Persistência:** Foi realizada a injeção de uma **chave SSH pública** do atacante no diretório `/root/.ssh/authorized_keys`. Isso garante que, mesmo que a vulnerabilidade na aplicação web (DVWA) seja corrigida, o atacante mantenha acesso persistente e direto via SSH como root.

---

# 7. Avaliação de Risco

* **Classificação:** Crítico  
* **Impacto:** Controle total e irrestrito sobre o servidor, arquivos do sistema e interceptação de tráfego de rede.  
* **Complexidade:** Baixa (Abuso de uma falha trivial de configuração administrativa/sudoers).

---

# 8. Mitigações Recomendadas

* **Princípio do Menor Privilégio:** Remover imediatamente a entrada `NOPASSWD` para o usuário `www-data` no arquivo `/etc/sudoers`. Usuários de serviço nunca devem ter permissão de executar binários que permitam escape de shell.
* **Hardening:** Consultar regularmente o projeto **GTFOBins** para identificar binários instalados que possuam funções de execução de comandos (`exec`, `read`, `write`) e restringir rigorosamente seu uso em configurações de privilégios elevados.

---

# 9. Defesa (Blue Team Perspective)

**Indicadores de Comprometimento (IoCs):**
* **Logs de Auditoria:** Detecção da execução do binário `find` acompanhado da flag `-exec` por usuários de baixo privilégio ou contas de serviço.
* **Auth Logs:** Monitoramento constante do arquivo `/var/log/auth.log` em busca de chamadas de `sudo` bem-sucedidas originadas por contas como `www-data`, `apache` ou `nginx`.

---

# 10. Apêndice – Evidências

**Evidence 01:** Saída dos comandos `id` e `whoami` confirmando o contexto de execução como `uid=0(root)`.  
**Evidence 02:** Captura de tela do conteúdo do arquivo `/etc/shadow`, comprovando a quebra total da barreira de permissões e o acesso a dados sensíveis do sistema.

---

# 11. Conclusão

A escalada de privilégios no Alvo 01 foi bem-sucedida através do abuso de configurações de `sudo` mal implementadas. O comprometimento deste host é total, servindo agora como uma **base sólida e privilegiada** para a progressão do ataque (pivoting) contra o Alvo 02 (Windows 10) e demais ativos críticos da rede interna.