// Author: Ruslan Zaporojets
// Email:  ruzzzua[]gmail.com
// Date:   2017-05-25

#include <windows.h>
#include <objbase.h>
#include "mcrt.h"

const TCHAR* commandLineSkipExePath(const TCHAR *s)
{
    if (!s)
        return s;
    if (TEXT('"') == *s)
    {
        ++s;
        for (; *s && *s != TEXT('"'); ++s);
        if (TEXT('"') == *s)
            ++s;
    }
    else
        for (; *s > TEXT(' '); ++s);
    for (; *s && *s <= TEXT(' '); ++s);
    return s;
}

HANDLE runProcessEx(const TCHAR *path, WORD cmdShow)
{
    size_t size = (tcslen(path) + 1) * sizeof(TCHAR);
    if (!size)
        return NULL;
    TCHAR *buf = (TCHAR *)VirtualAlloc(NULL, size, MEM_COMMIT, PAGE_READWRITE);
    if (!buf)
        return NULL;
    memset(buf, 0, size);
    memcpy(buf, path, size);

    STARTUPINFO si;
    memset(&si, 0, sizeof(si));
    si.cb = sizeof(si);
    si.dwFlags = STARTF_USESHOWWINDOW;
    si.wShowWindow = cmdShow;
    PROCESS_INFORMATION pi;
    memset(&pi, 0, sizeof(pi));
    DWORD flags = CREATE_DEFAULT_ERROR_MODE;
#ifdef _UNICODE
    flags ^= CREATE_UNICODE_ENVIRONMENT;
#endif
    BOOL ok = CreateProcess(0, buf, 0, 0, 0, flags, 0, 0, &si, &pi);
    DWORD le;
    if (!ok)
        le = GetLastError();
    VirtualFree(buf, 0, MEM_RELEASE);
    if (!ok)
    {
        SetLastError(le);
        return NULL;
    }
    CloseHandle(pi.hThread);
    return pi.hProcess;
}

HANDLE runShellEx(HWND wnd,
    const TCHAR *op,
    const TCHAR *path,
    const TCHAR *params,
    const TCHAR *dir,
    WORD cmdShow)
{
    BOOL cook = S_OK == CoInitializeEx(NULL,
        COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
    SHELLEXECUTEINFO sei;
    memset(&sei, 0, sizeof(sei));
    sei.cbSize = sizeof(SHELLEXECUTEINFO);
    sei.fMask = SEE_MASK_NOASYNC | SEE_MASK_NOCLOSEPROCESS | SEE_MASK_FLAG_NO_UI;
#ifdef _UNICODE
    sei.fMask ^= SEE_MASK_UNICODE;
#endif
    sei.hwnd = wnd;
    sei.lpVerb = op;
    sei.lpFile = path;
    sei.lpParameters = params;
    sei.lpDirectory = dir;
    sei.nShow = cmdShow;
    BOOL ok = ShellExecuteEx(&sei);
    DWORD le;
    if (!ok)
        le = GetLastError();
    if (cook)
        CoUninitialize();
    if (!ok)
    {
        SetLastError(le);
        return NULL;        
    }
    return sei.hProcess;
}

BOOL waitProcess(HANDLE hProcess, DWORD msWait)
{
    // Wait until app has finished initialization
    if (!hProcess)
        return FALSE;
    BOOL ret = WaitForInputIdle(hProcess, msWait) != 0 ? FALSE : TRUE;
    CloseHandle(hProcess);
    return ret;
}

BOOL isElevated()
{
    BOOL ret = FALSE;
    HANDLE hToken = NULL;
    if (OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &hToken))
    {
        TOKEN_ELEVATION elevation;
        DWORD size = sizeof(TOKEN_ELEVATION);
        if (GetTokenInformation(hToken, TokenElevation, &elevation,
                sizeof(elevation), &size))
            ret = elevation.TokenIsElevated;
    }
    if (hToken)
        CloseHandle(hToken);
    return ret;
}

BOOL isVista()
{
    OSVERSIONINFO ver;
    ver.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
    GetVersionEx(&ver);
    return (ver.dwPlatformId == VER_PLATFORM_WIN32_NT
        && ver.dwMajorVersion >= 6);
}

#if _WIN64

#pragma function(memset)
void* __cdecl memset(void *dest, int value, size_t num)
{
    unsigned char *p = (unsigned char *)dest;
    while (num-- > 0)
        *p++ = (unsigned char)value;
    return dest;
}

#pragma function(memcpy)
void* __cdecl memcpy(void *dest, const void *source, size_t num)
{
    char *pd = (char *)dest;
    const char *ps = (const char *)source;
    while (num-- > 0)
        *pd++ = *ps++;
    return dest;
}

#pragma function(wcslen)
size_t __cdecl wcslen(const wchar_t *str)
{
    size_t len = 0;
    while (*str++)
        ++len;
    return len;    
}

#pragma function(strlen)
size_t __cdecl strlen(const char *str)
{
    size_t len = 0;
    while (*str++)
        ++len;
    return len;
}

#else // _WIN32

#pragma function(memset)
void* __cdecl memset(void *dest, int value, size_t num)
{
    _asm
    {
        push ecx
        push edi
        mov eax, value
        mov ecx, num
        mov edi, dest
        rep stosb
        pop edi
        pop ecx
    }
    return dest;
}

#pragma function(memcpy)
void* __cdecl memcpy(void *dest, const void *source, size_t num)
{
    _asm
    {
        push ecx
        push edi
        push esi
        mov  ecx, num
        mov  edi, dest
        mov  esi, source
        rep  movsb
        pop  esi
        pop  edi
        pop  ecx
    }
    return dest;
}

#pragma function(wcslen)
size_t __cdecl wcslen(const wchar_t *s)
{
    _asm
    {
        push  edi
        mov   edi, s
        sub   ecx, ecx
        not   ecx
        sub   ax, ax
        cld
        repne scasw
        not   ecx
        pop   edi
        lea   eax, [ecx-1]
    }
}

#pragma function(strlen)
size_t __cdecl strlen(const char *s)
{
    _asm
    {
        push  edi
        mov   edi, s
        sub   ecx, ecx
        not   ecx
        sub   al, al
        cld
        repne scasb
        not   ecx
        pop   edi
        lea   eax, [ecx-1]
    }
}

#endif // _WIN64
