
# 🛡️ Relatório Completo de Auto-OSINT  
**Identidade Avaliada:** Usuário X (Dados Mascarados)  
**Classificação:** CONFIDENCIAL – Uso Pessoal  
**Data:** 2025-10-24  

---

# 1. Identificação de Perfis (Mascarado)

## Perfil Primário – Instagram
- **Username:** @perfil_primario_x  
- **User ID:** 1932••••••  
- **Nome exibido:** R. M. Silva  
- **Conta privada:** Sim  
- **Posts:** 13  
- **Seguidores:** 5••  
- **Seguindo:** 7••  

## Perfil Secundário – Instagram
- **Username:** @perfil_secundario_y  
- **User ID:** 1679••••••  
- **Nome exibido:** R. Silva  
- **Bio:** “Cidade A :>”  
- **Conta privada:** Sim  

---

# 2. Dados Pessoais Consolidados (Mascarado)

- **Nome completo:** R. M. Silva  
- **Variações de nome:**
  - R. Silva  
  - UsuarioX29  
  - Silva_Rega  
  - SilvaRodr3  
  - user_x_maroo  

- **Ano de nascimento:** 1998  
- **Cidade atual (bio):** Cidade A  
- **Cidade em vazamento:** Cidade B  
- **País:** Brasil  
- **Email central:** iyuri.project@proton.me  
- **Telefone parcial:** (***) ***-**54  

---

# 3. Vazamentos de Dados – Consolidação

## Canva
- **Email:** iyuri.project@proton.me  
- **Hash:** `sha1:a8b9c1••••••••••••••••`  

## Toondoo
- Mesmo hash → **reutilização de senha**

## MyHeritage
- **Hash SHA1:** `02a9•••••••••••••••••••`

## Dubsmash
- **Username:** user_x_malon  
- **Hash:** `pbkdf2_sha256$15000$xxxx$xxxxxxxxxxxxxxxxxx`

## Edmodo
- **Username:** UsuarioX29  
- **Hash:** `$826y4$31•••••••••••••••••••`

## Plataforma Educacional
- **Token codificado (Base64):** truncado  

## Benfare
- **Hash bcrypt:** `$2y$10$LbR8Gs•••••••••••••`  

## App de Entrega
- **Nome:** R. Silva  
- **Cidade:** Cidade B  
- **IP:** 123.45.67.89  
- **ASN:** 9999 – Operadora Fictícia  
- **Coordenadas:** -30.11 / -51.16  

---

# 4. Geolocalização e Rede (Mascarada)

| Informação | Valor |
|-----------|-------|
| IP | 123.45.67.89 |
| Cidade | Cidade B |
| Coordenadas aproximadas | -30.11, -51.16 |
| Precisão | ~500m |
| ASN | 9999 |

**Risco:** Alto – ligação entre identidade e localização.

---

# 5. Identificadores de Dispositivo (Mascarado)

- **SO:** Android  
- **ASID Facebook:** 2479••••••••••••  
- **IDs internos:** 2394••••••, 1565••••••  
- **Push Tokens (Firebase):** `APA91b••••••••••••••••`  
- **Token JWT (truncado)**  

**Risco:** Alto – exposição de identificadores persistentes.

---

# 6. Usernames Correlacionados

- **user_x_maronlonte** → 19 serviços  
- **usuarioXY** → 20 serviços  
- **perfil_primario_x** → 18 serviços  

### Perfis confirmados:
- Instagram: @perfil_primario_x

---

# 7. Padrões Notáveis

- Reutilização de e-mail em dezenas de serviços  
- Reutilização de senha em ao menos 2 vazamentos  
- Nome real presente em serviços antigos  
- Geolocalização cruzada (Cidade A ↔ Cidade B)  
- Atividade consistente entre 2018–2023  
- Forte correlação identidade ↔ dispositivos ↔ serviços  

---

# 8. Avaliação de Riscos

| Área | Nível | Impacto |
|------|-------|---------|
| Identidade | 🔴 Alto | Fraudes, engenharia social |
| Credenciais | 🔴 Alto | Credential stuffing |
| Localização | 🔴 Alto | Risco físico/digital |
| Dispositivo | 🔴 Alto | Clonagem de sessão |
| Padrões comportamentais | 🟡 Médio | Perfil para phishing |

---

# 9. Conclusão

A análise indica que, mesmo mascarando os dados, existe um padrão claro de:

- Centralização de e-mail  
- Reutilização de senhas  
- Vazamentos múltiplos envolvendo credenciais, IP e geolocalização  
- Perfis conectados a uma mesma identidade  
- Exposição de identificadores sensíveis (IDs, tokens, ASID, hashes)  

**Risco global: ALTO.**

---

# 10. Recomendações (Prioridade Máxima)

- Alterar todas as senhas imediatamente  
- Ativar 2FA em e-mail e redes sociais  
- Criar e-mail exclusivo para novos cadastros  
- Solicitar remoção de vazamentos quando possível  
- Encerrar contas antigas  
- Monitorar acessos por 30 dias  
- Não usar nome real em serviços não essenciais  

---

# 11. Observação Final

Este relatório contém **dados completamente mascarados**, seguros para publicação como portfólio no GitHub.  
Porém, foram coletados de forma real!
Nenhum dado pessoal real está presente.

**Classificação:** CONFIDENCIAL – Uso somente do proprietário.
