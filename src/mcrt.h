// Author: Ruslan Zaporojets
// Email:  ruzzzua[]gmail.com
// Date:   2017-05-25

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

const TCHAR* commandLineSkipExePath(const TCHAR *s);
// Return process handle
HANDLE runProcessEx(const TCHAR *path, WORD cmdShow);
HANDLE runShellEx(HWND wnd,
    const TCHAR *op,
    const TCHAR *path,
    const TCHAR *params,
    const TCHAR *dir,
    WORD cmdShow);
BOOL waitProcess(HANDLE hProcess, DWORD msWait);
BOOL isElevated();
BOOL isVista();

void* __cdecl memset(void*, int, size_t);
void* __cdecl memcpy(void*, const void*, size_t);
size_t __cdecl wcslen(const wchar_t*);
size_t __cdecl strlen(const char*);

#ifdef __cplusplus
}
#endif

#ifdef _UNICODE
#define tcslen wcslen
#else
#define tcslen strlen
#endif

inline HANDLE runProcess(const TCHAR *path)
{
    return runProcessEx(path, SW_SHOWNORMAL);
}

inline HANDLE runShell(const TCHAR *op, const TCHAR *path, const TCHAR *params)
{
    return runShellEx(NULL, op, path, params, NULL, SW_SHOWNORMAL);
}