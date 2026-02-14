import scapy.all as scapy
import requests
import sys
''' como utilizar este script:  Como o script usa o Scapy para manipular pacotes em nível 2, ele deve ser rodado como root: sudo python3 ultra_recon_pro.py 192.168.1.10.'''


def get_mac_vendor(mac_address):
    """Consulta API para identificar fabricante do dispositivo"""
    try:
        url = f"https://api.macvendors.com/{mac_address}"
        response = requests.get(url)
        return response.text if response.status_code == 200 else "Vendor Desconhecido"
    except:
        return "Erro na Consulta"

def analyze_ttl(ttl):
    """Predição de SO baseada no Time To Live (TTL)"""
    if ttl <= 64:
        return "Linux/Unix (ou Mobile)"
    elif ttl <= 128:
        return "Windows"
    else:
        return "Sistema Desconhecido/Network Device"

def scan(ip):
    print(f"\n[+] Iniciando Reconhecimento Pro em: {ip}")
    print("-" * 50)
    
    # ARP Request para pegar MAC
    arp_req = scapy.ARP(pdst=ip)
    broadcast = scapy.Ether(dst="ff:ff:ff:ff:ff:ff")
    packet = broadcast/arp_req
    answered = scapy.srp(packet, timeout=2, verbose=False)[0]

    if answered:
        mac = answered[0][1].hwsrc
        vendor = get_mac_vendor(mac)
        
        # ICMP para pegar TTL
        icmp_packet = scapy.sr1(scapy.IP(dst=ip)/scapy.ICMP(), timeout=1, verbose=False)
        ttl = icmp_packet.ttl if icmp_packet else "N/A"
        os_guess = analyze_ttl(ttl) if icmp_packet else "Host possivelmente bloqueando ICMP"

        print(f"IP: {ip}")
        print(f"MAC: {mac}")
        print(f"Vendor: {vendor}")
        print(f"TTL: {ttl}")
        print(f"OS Guess: {os_guess}")
    else:
        print("[-] Host não respondeu ao ARP. Verifique a rede.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Uso: sudo python3 ultra_recon_pro.py <IP_ALVO>")
    else:
        scan(sys.argv[1])
