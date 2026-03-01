import os
from PIL import Image
from PIL.ExifTags import TAGS, GPSTAGS

"""
🛰️ RECON TOOL: Metadata Extractor
---------------------------------------------------------
DESCRIÇÃO:
    Script desenvolvido para a Fase 02 de Reconhecimento Ativo.
    Automatiza a extração de metadados EXIF e coordenadas GPS 
    de arquivos de imagem para validar o perímetro físico do alvo.

REQUISITOS:
    - Python 3.x
    - Pillow (PIL): pip install Pillow

USO:
    1. Coloque as imagens alvo na pasta './evidences/exif/'
    2. Execute: python metadata_extractor.py

RESULTADO:
    - Coordenadas decimais prontas para geolocalização.
    - URL direta para o Google Maps.
---------------------------------------------------------
"""
def get_exif_data(image_path):
    """Extrai metadados EXIF de uma imagem."""
    try:
        image = Image.open(image_path)
        exif_data = image._getexif()
        if not exif_data:
            return None
        
        decoded_exif = {}
        for tag, value in exif_data.items():
            decoded = TAGS.get(tag, tag)
            if decoded == "GPSInfo":
                gps_data = {}
                for t in value:
                    sub_tag = GPSTAGS.get(t, t)
                    gps_data[sub_tag] = value[t]
                decoded_exif[decoded] = gps_data
            else:
                decoded_exif[decoded] = value
        return decoded_exif
    except Exception as e:
        print(f"[!] Erro ao processar {image_path}: {e}")
        return None

def convert_to_degrees(value):
    """Converte coordenadas GPS para formato decimal (Google Maps)."""
    d = float(value[0])
    m = float(value[1])
    s = float(value[2])
    return d + (m / 60.0) + (s / 3600.0)

def main():
    print("--- 🛰️ Recon Active: Metadata Extractor ---")
    target_dir = "./evidences/exif/"
    
    if not os.path.exists(target_dir):
        print(f"[!] Diretório {target_dir} não encontrado.")
        return

    for file in os.listdir(target_dir):
        if file.lower().endswith(('.png', '.jpg', '.jpeg')):
            print(f"\n[*] Analisando: {file}")
            exif = get_exif_data(os.path.join(target_dir, file))
            
            if exif and "GPSInfo" in exif:
                gps = exif["GPSInfo"]
                lat = convert_to_degrees(gps["GPSLatitude"])
                if gps["GPSLatitudeRef"] != "N": lat = 0 - lat
                
                lon = convert_to_degrees(gps["GPSLongitude"])
                if gps["GPSLongitudeRef"] != "E": lon = 0 - lon
                
                print(f"[+] Coordenadas Identificadas: {lat}, {lon}")
                print(f"[+] Link Google Maps: https://www.google.com/maps?q={lat},{lon}")
            else:
                print("[-] Nenhum dado de GPS encontrado.")

if __name__ == "__main__":
    main()
