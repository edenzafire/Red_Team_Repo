import socket
import sys

def grab_banner(ip, port):
    try:
        # Criando o socket (Conexão TCP)
        s = socket.socket()
        s.settimeout(2) # Não espera mais que 2 segundos
        s.connect((ip, port))
        
        # Recebe até 1024 bytes do serviço
        banner = s.recv(1024).decode().strip()
        return banner
    except:
        return None

def main():
    if len(sys.argv) < 2:
        print("Uso: python3 BannerHunter.py <IP>")
        sys.exit()

    target = sys.argv[1]
    # Portas comuns para testar
    ports = [21, 22, 25, 80, 445, 3389]
    
    print(f"[*] Analisando Banners em: {target}\n")
    print("| Porta | Serviço / Banner |")
    print("|-------|------------------|")

    for port in ports:
        banner = grab_banner(target, port)
        if banner:
            print(f"| {port} | {banner} |")
            # Lógica de "Análise Sênior"
            if "vsFTPd 2.3.4" in banner:
                print(f"  [!] ALERTA: Backdoor conhecido detectado na porta {port}!")
        else:
            print(f"| {port} | [Sem Resposta] |")

if __name__ == "__main__":
    main()
