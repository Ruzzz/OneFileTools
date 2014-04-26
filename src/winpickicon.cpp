#include <windows.h>
#include <shlobj.h>

#pragma comment(lib, "kernel32.lib")
#pragma comment(lib, "user32.lib")
#pragma comment(lib, "Shell32.lib")

void WINAPI main()
{
    int index = 0;
    // %SystemRoot%\system32\shell32.dll
    wchar_t path[34] = { L'%', L'S', L'y', L's', L't', L'e', L'm', L'R', L'o', L'o',
                         L't', L'%', L'\\', L's', L'y', L's', L't', L'e', L'm', L'3', L'2', L'\\',
                         L's', L'h', L'e', L'l', L'l', L'3', L'2', L'.', L'd', L'l', L'l', L'\0'
                       };
    if (!PickIconDlg(NULL, path, 34, &index))
        index = -1;
    ExitProcess(index);
}
