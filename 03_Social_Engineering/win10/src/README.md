## 🛠️ Operation Source Code (src)
Este diretório contém os artefatos técnicos utilizados na fase de Entrega (Delivery) e Exploração do Projeto 03. O foco desta etapa é a simulação de uma campanha de Engenharia Social altamente direcionada.

##📂 Inventário de Arquivos
**1. veneno.cpp**
Descrição: Código-fonte do payload principal desenvolvido em C++.

Função: Atua como o "agente" de persistência no host alvo (Win10-Lab).

Características: Implementa chamadas de sistema para estabelecer o reverse shell (Meterpreter) e garantir que o acesso seja mantido mesmo após reinicializações.
[Acessar veneno.cpp aqui](https://github.com/edenzafire/Red_Team_Repo/blob/main/03_Social_Engineering/src/veneno.cpp)

**2. encrypt.py**
Descrição: Script utilitário em Python para ofuscação.

Função: Realiza a criptografia/ofuscação do binário gerado pelo veneno.cpp (ex: via XOR).

Objetivo: Evadir assinaturas estáticas de antivírus e dificultar a análise inicial por ferramentas de monitoramento.
[Acessar encrypt.py aqui](https://github.com/edenzafire/Red_Team_Repo/blob/main/03_Social_Engineering/src/encrypt.py)

**3. generate_smuggling.py**
Descrição: Gerador automatizado de HTML Smuggling.

Função: Codifica o payload (o "veneno") em um blob JavaScript embutido em um arquivo HTML comum.

Técnica: Utiliza a técnica de HTML Smuggling para baixar o arquivo malicioso diretamente no navegador do usuário, contornando firewalls de borda que bloqueiam downloads diretos de executáveis.
[Acessar Gerador Smuggling.py aqui](https://github.com/edenzafire/Red_Team_Repo/blob/main/03_Social_Engineering/src/generate_smuggling.py)

**4. phishing.html**
Descrição: A "isca" visual da campanha.

Tema: Documentação técnica sobre luthieria e guitarras flamencas (Paco de Lucía/Hermanos Conde).

Função: É o arquivo que a vítima recebe. Ao ser aberto, ele renderiza o conteúdo de luthieria enquanto o script gerado pelo generate_smuggling.py entrega o payload silenciosamente.
[Acessar o smuggling pronto aqui](https://github.com/edenzafire/Red_Team_Repo/blob/main/03_Social_Engineering/src/phishing.html)

## 🚀 Fluxo de Execução
*O veneno.cpp* é compilado para um executável.

*O encrypt.py* ofusca o executável para reduzir a taxa de detecção.

*O generate_smuggling.py* empacota o binário ofuscado dentro do phishing.html.

O arquivo final é entregue ao alvo via Engenharia Social.

* Nota de Segurança: Todos os códigos contidos neste diretório são destinados estritamente a fins educacionais e de pesquisa em ambientes controlados (Lab.local).
