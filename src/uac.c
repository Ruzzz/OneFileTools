// Author: Ruslan Zaporojets
// Email:  ruzzzua[]gmail.com
// Date:   2017-05-25

#include <windows.h>
#include "mcrt.h"

void WINAPI main()
{   
    const TCHAR *cl = GetCommandLine();
    cl = commandLineSkipExePath(cl);
    if (!(cl && *cl))
        ExitProcess(1);
    
    HANDLE hProcess = NULL;
    if (!isElevated())
    {
        TCHAR exeName[MAX_PATH];
        if (GetModuleFileName(NULL, exeName, _countof(exeName)) > 0)
            hProcess = runShell(TEXT("runas"), exeName, cl);
    }
    else
        hProcess = runProcess(cl);

    if (hProcess)
    {
        CloseHandle(hProcess);
        ExitProcess(0);
    }
    else
        ExitProcess(1);
}
