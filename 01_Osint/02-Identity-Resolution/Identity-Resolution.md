# Resolução de Identidade (Identity Resolution)

## 1. Perfil Consolidado (Dados Confirmados)
* **Nome Principal:** [Seu Nome Completo]
* **Variações Encontradas:** [Primeiro Nome + Último Sobrenome] / [Iniciais]
* **E-mail Confirmado:** [seu_email@exemplo.com]
* **Usernames Confirmados:**
  * `@exemplo_dev` (Confirmado via e-mail de recuperação visível)
  * `@exemplo_oficial` (Confirmado via bio que aponta para o site pessoal)

---

## 2. Descarte de Homônimos (Falsos Positivos)
> Lista de perfis com o mesmo nome que NÃO pertencem ao alvo, para evitar conclusões erradas.

* **Perfil no LinkedIn (`linkedin.com/in/homonimo`):** Descartado (Reside em SP, atuação na área de Direito).
* **Processo Judicial (Jusbrasil):** Descartado (Mesmo nome, mas CPF parcial e cidade divergentes).

---

## 3. Matriz de Correlação de Identidade

| Identificador Encontrado | Tipo | Método de Validação | Status de Pertencimento |
| :--- | :--- | :--- | :--- |
| `@exemplo_game` | Username | Foto de perfil idêntica à do GitHub | [X] Confirmado |
| `old_mail@provider.com` | E-mail | Vinculado ao mesmo gravatar do e-mail principal | [X] Confirmado |
| `@exemplo_insta` | Username | Sem postagens, sem foto e criado em outro país | [ ] Descartado |

---

## 4. Próximos Passos
* Com a identidade confirmada e limpa de homônimos, utilizar os *usernames* e e-mails validados para alimentar as buscas nas pastas `04-Inteligência por e-mail` e `05-Nome de usuário-Inteligência`.
