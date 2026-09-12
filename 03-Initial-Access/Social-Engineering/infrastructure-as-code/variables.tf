variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "your_ip" {
  description = "Seu IP público (formato IP/32) para liberar acesso restrito ao SSH e Painel Admin"
  type        = string
  default     = "0.0.0.0/0" # ALERTA: Substitua pelo seu IP real (ex: "187.12.34.56/32")
}

variable "environment" {
  description = "Nome do ambiente para tag de recursos"
  type        = string
  default     = "RedTeam-Lab"
}
