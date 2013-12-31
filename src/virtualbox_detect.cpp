#include <windows.h>

#ifdef NOCRT
#define WINMAIN WINAPI
#else
#define WINMAIN
#endif

void WINMAIN main()
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
