import base64

# Lê o seu arquivo ISO que acabamos de criar
with open("entrega.iso", "rb") as f:
    encoded_string = base64.b64encode(f.read())

# Salva a string em um arquivo de texto para você copiar
with open("iso_base64.txt", "w") as f:
    f.write(encoded_string.decode('utf-8'))

print("Sucesso! A string Base64 foi salva em 'iso_base64.txt'.")
print("Abra esse arquivo, copie tudo e cole no seu HTML.")
