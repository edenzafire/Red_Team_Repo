terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Chave SSH para acesso à máquina
resource "aws_key_pair" "gophish_key" {
  key_name   = "gophish-lab-key"
  public_key = file("~/.ssh/id_rsa.pub") # Certifique-se de ter uma chave SSH gerada em seu sistema
}

# 2. Security Group (Firewall)
resource "aws_security_group" "gophish_sg" {
  name        = "gophish-lab-security-group"
  description = "Regras de Firewall para o GoPhish C2 Server"

  # Entrada SSH (Restrito apenas ao seu IP)
  ingress {
    description = "SSH de Gerenciamento"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
  }

  # Painel Admin do GoPhish (Restrito apenas ao seu IP)
  ingress {
    description = "GoPhish Admin Console"
    from_port   = 3333
    to_port     = 3333
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
  }

  # Tráfego HTTP da página de Phishing (Público para testes)
  ingress {
    description = "Phishing Landing Page (HTTP)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tráfego HTTPS (Para SSL futuro com Certbot/LetsEncrypt)
  ingress {
    description = "Phishing Landing Page (HTTPS)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Saída liberada para a internet (Atualizações e pacotes)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-SG"
  }
}

# 3. Busca a imagem oficial mais recente do Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 4. Instância EC2 (Servidor GoPhish)
resource "aws_instance" "gophish_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" # Elegível para a Free Tier da AWS

  key_name               = aws_key_pair.gophish_key.key_name
  vpc_security_group_ids = [aws_security_group.gophish_sg.id]

  user_data = file("${path.module}/scripts/user_data.sh")

  tags = {
    Name = "${var.environment}-GoPhish-Server"
  }
}

# 5. Elastic IP (IP Público Estático para o Servidor)
resource "aws_eip" "gophish_eip" {
  instance = aws_instance.gophish_server.id
  domain   = "vpc"

  tags = {
    Name = "${var.environment}-EIP"
  }
}
