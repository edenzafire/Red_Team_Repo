# 🕵️ Ferramentas Utilizadas – Projeto OSINT

Este documento lista as principais ferramentas, métodos e recursos utilizados durante a investigação OSINT, organizadas por categorias para facilitar referência, auditoria e reprodutibilidade dos resultados.

---

## 1. 🔍 Coleta de Dados – Identidades e Contas Online

### **Holehe**

* Função: verifica se um e-mail está registrado em diversos serviços online.
* Utilidade: identificação de presença digital e possíveis plataformas vinculadas.

### **Sherlock**

* Função: busca usernames em centenas de sites e redes sociais.
* Utilidade: enumeração de perfis associados ao mesmo nome de usuário.

### **WhatsMyName**

* Função: identifica a existência de usernames cadastrados em múltiplos sites.
* Diferencial: complemento ao Sherlock com fontes diferentes.

### **Google Dorks**

* Função: consultas avançadas via Google para informações expostas.
* Exemplos:

  * `site:facebook.com "nome completo"`
  * `inurl:pastebin email@dominio.com`
* Utilidade: localizar dados indexados publicamente.

### **Scraping / Navegação Manual**

* Função: coleta manual de dados verificados diretamente na fonte.
* Utilidade: validação visual, captura de metadados e cruzamento de informação.

---

## 2. 🧾 Vazamentos e Leaks

### **hstrike**

* Função: consulta bases de dados vazadas em massa.
* Utilidade: localizar credenciais, informações pessoais e associações.

### **HaveIBeenPwned**

* Função: detecção de vazamentos públicos vinculados a e-mails.
* Utilidade: confirmar exposição em leaks conhecidos.

### **DeHashed / Snusbase**

* Função: mecanismos de busca em dumps e bancos de dados vazados.
* Utilidade: validação de ocorrência e profundidade da exposição.

### **Dumps SQL e Bases Vazadas**

* Função: análise direta de vazamentos obtidos.
* Utilidade:

  * Confirmar CPF, telefone, hashes de senha, endereços etc.
  * Cruzar dados entre vazamentos.

---

## 3. 📱 Análise de Redes Sociais

### **Instagram OSINT API**

* Função: coleta de perfis, metadados, seguidores e informações públicas.
* Utilidade: reconstrução de presença social.

### **Ferramentas de Download/Análise de Mídia**

* Função: baixar publicações para estudo local.
* Informação importante:

  * Instagram **não notifica o usuário** em downloads de fotos públicas.

---

## 4. 🧠 Inteligência, Tratamento e Organização

### **Scripts Python Produzidos**

Utilizados para:

* Extração e processamento de listas de vazamentos
* Conversão de dumps para CSV
* Normalização de dados
* Cruzamento de fontes

Os scripts serão organizados em uma pasta  separada (`scripts_osint`).

### **grep / awk / sed / jq**

* Função: análise e filtragem de grandes volumes de texto e JSON via terminal.

### **Planilhas (CSV / Excel)**

* Função: tabulação de resultados para visualização e documentação.

---

## 5. 🧩 Metodologia

A metodologia geral seguiu os seguintes passos:

1. Coleta de identificadores (e-mail, nome, telefone, usuário)
2. Busca sistemática em:

   * redes sociais
   * motores de busca
   * bancos de dados vazados
   * consultas por APIs e ferramentas OSINT
3. Validação manual e automatizada
4. Organização dos dados extraídos
5. Montagem de relatório consolidado

---

## 6. 🔒 Considerações Éticas

* Toda coleta realizada a partir de fontes públicas ou legalmente acessíveis.
* A finalidade é educacional, de defesa e de análise de exposição digital.
* Nenhuma tentativa de invasão, brute-force ou exploração ativa foi executada.

---

## 7. 📌 Status Atual

* Estrutura de coleta concluída
* Relatório compilado
* Repositório organizado com:

  * `/relatorios`
  * `/scripts`
  * `/fontes`
  * `/dumps`

