#!/bin/bash
set -e

# Atualização do sistema e instalação de dependências
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common git

# Instalação do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=\((dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu\)(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Inicia o serviço do Docker
sudo systemctl enable docker
sudo systemctl start docker

# Clona o repositório oficial do GoPhish / prepara docker-compose
mkdir -p /opt/gophish
cd /opt/gophish

# Download do binário ou execução via container oficial
# Para facilidade de setup e persistência no laboratório, vamos usar a imagem oficial do GoPhish
cat << 'EOF' > docker-compose.yml
version: '3.3'
services:
  gophish:
    image: gophish/gophish:latest
    container_name: gophish
    ports:
      - "80:80"       # Porta HTTP pública da Landing Page de Phishing
      - "3333:3333"   # Porta do Admin Console (Restrita ao operador via Security Group)
    restart: always
EOF

sudo docker compose up -d || sudo docker-compose up -d
