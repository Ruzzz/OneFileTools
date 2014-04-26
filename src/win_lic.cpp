#include <windows.h>

#pragma comment(lib, "kernel32.lib")  // GetStdHandle, WriteFile
#pragma comment(lib, "Advapi32.lib")  // RegOpenKeyExA, RegQueryValueExA, RegCloseKey
#pragma comment(lib, "msvcrt.lib")  // memset (see {0}), strlen

void print(char const *s)
{
    DWORD countPrinted;
    static HANDLE hStd = GetStdHandle(STD_OUTPUT_HANDLE);
    WriteFile(hStd, s, strlen(s), &countPrinted, NULL);
}

bool readKeyValue(HKEY hRootKey, char const *subKey, char const *value, void *buffer, ULONG size)
{
    HKEY hKey;
    LONG result = RegOpenKeyExA(hRootKey, subKey, 0, KEY_READ | KEY_WOW64_64KEY, &hKey);
    if (result == ERROR_SUCCESS)
    {
        result = RegQueryValueExA(hKey, value, 0, 0, (LPBYTE)buffer, &size);
        RegCloseKey(hKey);
        return result == ERROR_SUCCESS;
    }
    return false;
}

int main()
{
    const char ROOT_KEY[45] = { 'S', 'o', 'f', 't', 'w', 'a', 'r', 'e', '\\',
                                'M', 'i', 'c', 'r', 'o', 's', 'o', 'f', 't', '\\', 'W', 'i', 'n', 'd',
                                'o', 'w', 's', ' ', 'N', 'T', '\\', 'C', 'u', 'r', 'r', 'e', 'n', 't',
                                'V', 'e', 'r', 's', 'i', 'o', 'n', L'\0'
                              };
    char productId[200] = {0};
    if (readKeyValue(HKEY_LOCAL_MACHINE, ROOT_KEY, "ProductId", &productId, sizeof(productId)))
    {
        print("Product ID: ");
        print(productId);
        print("\n");
    }
    return 0;
}
