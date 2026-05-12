import sys
def xor(data, key):
    return bytearray([b ^ key for b in data])
if len(sys.argv) < 2:
    print("Uso: python3 encrypt.py shellcode.bin")
    sys.exit()
with open(sys.argv[1], "rb") as f:
    print(", ".join([hex(b) for b in xor(f.read(), 0x77)]))
