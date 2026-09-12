output "public_ip" {
  description = "IP Público Fixo do Servidor GoPhish"
  value       = aws_eip.gophish_eip.public_ip
}

output "gophish_admin_url" {
  description = "URL do Painel Administrativo do GoPhish"
  value       = "https://${aws_eip.gophish_eip.public_ip}:3333"
}

output "gophish_phishing_url" {
  description = "URL da Landing Page de Phishing"
  value       = "http://${aws_eip.gophish_eip.public_ip}"
}
