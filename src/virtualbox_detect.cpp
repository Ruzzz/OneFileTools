#include <windows.h>

#pragma comment(lib, "kernel32.lib")

void WINAPI main()
{
    bool detected = LoadLibraryA("VBoxHook.dll") != NULL
        && CreateFileA("\\\\.\\VBoxMiniRdrDN",
            GENERIC_READ,
            FILE_SHARE_READ,
            NULL,
            OPEN_EXISTING,
            FILE_ATTRIBUTE_NORMAL,
            NULL) != INVALID_HANDLE_VALUE;
    ExitProcess(detected ? 1 : 0);
}
