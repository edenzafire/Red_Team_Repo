# Planejamento de Investigação (Self-OSINT)

## 1. Escopo e Objetivos
* **Tipo de Investigação:** Self-OSINT / Auditoria de Pegada Digital
* **Objetivo Principal:** Mapear dados pessoais expostos publicamente na internet e identificar possíveis vetores de ataque/risco.
* **Metodologia:** Coleta passiva (sem interação direta com os serviços ou envio de pacotes intrusivos).
* **Data de Início:** 21/08/2026
* **Status:** Em Andamento

---

## 2. Vetores de Entrada (Dados Semente)
> **Nota:** Todos os novos dados descobertos durante as buscas devem ser adicionados nesta seção como vetores secundários.

* **Nome Completo:** [Seu Nome Completo Aqui]
* **E-mail Principal:** [seu_email@exemplo.com]

### Vetores Secundários (A descobrir)
* **Usernames:** *Pendente*
* **Telefones:** *Pendente*
* **Documentos/CPFs:** *Pendente*

---

## 3. Matriz de Execução e Pivoteamento

| Vetor de Origem | Ação Planejada | Ferramenta / Fonte | Pasta Destino | Status |
| :--- | :--- | :--- | :--- | :--- |
| **E-mail** | Checar exposição em vazamentos de dados | Have I Been Pwned | `09-Violações-Inteligência` | [ ] Pendente |
| **E-mail** | Identificar contas e serviços associados | E-mail OSINT / Google Dorks | `04-Inteligência por e-mail` | [ ] Pendente |
| **E-mail / Nome** | Mapear *usernames* atrelados | WhatsMyName / Sherlock | `05-Nome de usuário-Inteligência` | [ ] Pendente |
| **Nome Completo** | Buscar registros em Diários Oficiais e Jusbrasil | Google Dorking / Bing | `03-Registros-Públicos` | [ ] Pendente |
| **Nome Completo** | Auditar presença pública em redes sociais | Análise manual (Aba Anônima) | `06-Inteligência em Mídias Sociais` | [ ] Pendente |

---

## 4. Registro de Riscos e Boas Práticas (OpSec)
* **Isolamento de Ambiente:** Navegar sempre com VPN ativa e utilizar abas anônimas para evitar personalização de resultados baseada em cookies pessoais.
* **Chaves de API:** Garantir que nenhum arquivo de configuração (`.env`) contendo chaves pessoais seja enviado para o repositório público no GitHub.
* **Preservação de Provas:** Salvar capturas de tela e links relevantes de forma imediata na pasta `evidências/`.

---

## 5. Histórico de Atualizações
* **21/08/2026:** Criação do documento de planejamento e definição dos vetores semente.
