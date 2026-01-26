Superfície de ataque por ASN (print mais importante)

asn:8167 country:BR

Serviços mais comuns no ASN

asn:8167 port:80
asn:8167 port:443
asn:8167 port:22

Identificação de dispositivos de borda

asn:8167 product:Router
asn:8167 product:Modem

Dispositivos IoT expostos

asn:8167 category:iot

Tecnologias web comuns

asn:8167 product:Apache
asn:8167 product:nginx

País + porta (visão macro)
country:BR port:3389
country:BR port:445

🌐 CENSYS — Se quiser complementar (opcional)
🔹 7. Serviços TLS mais comuns

services.tls.certificates.leaf_data.subject.organization:*

HTTP Titles interessantes

services.http.response.html_title:*

🔍 WHOIS / ASN LOOKUP — Prints rápidos e limpos
🔹 9. ASN detalhado

Nome da organização

Range de IP

País

ISP

📸 Print da página do ASN.

🧠 Demonstra:

Entendimento de backbone e roteamento.

🔹 10. Histórico de IP (se aparecer)

Mudança de ASN

Mudança de bloco

🧠 Demonstra:

Correlação histórica.

🧰 GOOGLE DORKS (Recon clássico)
🔹 11. Dispositivos expostos

site:login "admin"
site:panel "dashboard"




## 🛠️ Metodologia Técnica: Footprinting de Infraestrutura (Shodan & Censys)

Nesta etapa, utilizei motores de busca de dispositivos (IoT Search Engines) para mapear o ecossistema do ISP utilizado pelo alvo, permitindo entender o contexto de rede e os dispositivos de borda comuns na região.

### 🌐 SHODAN — Inteligência de ASN e Serviços
Utilizei as seguintes queries para identificar padrões de exposição no **ASN:8167 (V Tal / Brasil Telecom)**:

* **Mapeamento de Superfície por ASN:** `asn:8167 country:BR`  
    *(Demonstra: Visão macro da infraestrutura do provedor no país).*
* **Identificação de Serviços Críticos:** * `asn:8167 port:80,443,22` (Web e Administração Remota)
    * `asn:8167 product:Router` ou `product:Modem` (Dispositivos de Borda)
* **Vetores de IoT e Protocolos Vulneráveis:**
    * `asn:8167 category:iot` (Câmeras, DVRs e Smart Devices)
    * `country:BR port:3389,445` (Exposição de RDP e SMB em nível nacional)

> **🧠 Insight de Inteligência:** A análise de tecnologias comuns (`product:Apache`, `product:nginx`) no ASN permitiu prever o stack tecnológico que o alvo provavelmente utiliza em seu laboratório.

---

### 📡 CENSYS — Fingerprinting TLS e HTTP
O Censys foi utilizado para complementar a visão do Shodan, focando em certificados e cabeçalhos:

* **Serviços TLS Dominantes:** `services.tls.certificates.leaf_data.subject.organization:*`
* **Análise de Cabeçalhos HTTP:** `services.http.response.html_title:*`  
    *(Útil para identificar painéis de login e dashboards de gerenciamento expostos).*

---

### 🔍 WHOIS & HISTORICAL LOOKUP
Documentação do backbone e roteamento para entender a persistência do alvo na rede:

1.  **ASN Detail:** Identificação do range de IP, Organização e ISP oficial.
2.  **IP History:** Análise de mudanças históricas de blocos e ASN, demonstrando correlação entre a persona e diferentes períodos de conectividade.

---

### 🧰 GOOGLE DORKS (Advanced Recon)
Consultas avançadas para localizar pontos de entrada administrativos indexados:

* `site:login "admin"` – Busca por portais de autenticação.
* `site:panel "dashboard"` – Identificação de painéis de controle e monitoramento.

---
