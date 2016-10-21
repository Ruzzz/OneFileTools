/// Author: Zaporojets Ruslan
/// Email:  ruzzzua[]gmail.com
/// Date:   2015-09-03

// TODO:
//   - Not console version

#include <windows.h>

#pragma comment(lib,"kernel32.lib")
#pragma comment(lib,"user32.lib")
#pragma comment(lib,"shell32.lib")

//
//  Consts
//

#define WINDOW_PROGMAN        "Progman"
#define WINDOW_SHELL_TRAY     "Shell_TrayWnd"
#define SHELL_FILENAME        "explorer.exe"
#define EXIT_CHECK_PRE_SLEEP  1000
#define EXIT_CHECK_COUNT      100
#define EXIT_CHECK_STEP_SLEEP 100

const char USAGE[] =
{
    "ExplorerTools v1.0 by Ruslan Zaporojets\n"
    "Usage: texplorer.exe -r|-e|-s\n"
    "\n"
    "Actions:\n"
    "  -r                      - Safe restart.\n"
    "  -e                      - Safe exit only.\n"
    "  -s                      - If not running then start.\n"
};

enum
{
    RESULT_OK = 0,
    RESULT_ERROR_CANT_EXIT,
    RESULT_ERROR_TOO_LONG_EXIT,
    RESULT_ERROR_CANT_START,
    RESULT_ALREADY_RUNNING
};

enum
{
    ACTION_INVALID = 0,
    ACTION_RESTART = 1,
    ACTION_EXIT_ONLY,
    ACTION_START_IF_NOT_RUNNING
};

const char *MESSAGE[] =
{
    0,
    "Explorer cant exit!",
    "Explorer is too long exit!",
    "Explorer cant start!",
    "Explorer already running!"
};

//
//  Helpers
//

// Uses asm version. Smart compiler dont replace it by built-in memset.
__inline
void zeroMemory(void *p, size_t count)
{
    _asm
    {
        push ecx
        push edi
        mov al, 0
        mov ecx, count
        mov edi, p
        rep stosb
        pop edi
        pop ecx
    }
}

unsigned int strlen(const char *s)
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

BOOL run(TCHAR *path)
{
    STARTUPINFO si;
    zeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    PROCESS_INFORMATION pi;
    zeroMemory(&pi, sizeof(pi));
    if (!CreateProcess(NULL, path, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi))
        return FALSE;
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
    return TRUE;
}

BOOL isVista()
{
    OSVERSIONINFO ver;
    ver.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
    GetVersionEx(&ver);
    if (ver.dwPlatformId == VER_PLATFORM_WIN32_NT && ver.dwMajorVersion >= 6)
        return TRUE;
    else
        return FALSE;
}

//
//  Core
//

// http://stackoverflow.com/questions/5689904/gracefully-exit-explorer-programmatically
__inline
BOOL safeExitExplorerVista()
{
    HWND hWndTray = FindWindow(TEXT(WINDOW_SHELL_TRAY), NULL);
    return PostMessage(hWndTray, 0x5B4, 0, 0);
}

BOOL safeExitExplorerXP_1()
{
    HWND hWndProgMan = FindWindow(TEXT(WINDOW_PROGMAN), NULL);
    if (PostMessage(hWndProgMan, WM_QUIT, 0, TRUE) != FALSE)
    {
        HWND hWndTray = FindWindow(TEXT(WINDOW_SHELL_TRAY), NULL);
        return PostMessage(hWndTray, WM_QUIT, 0, 0);
    }
    else
        return FALSE;
}

BOOL safeExitExplorerXP_2()
{
    HWND hWndProgMan = FindWindow(TEXT(WINDOW_PROGMAN), NULL);
    return PostMessage(hWndProgMan, WM_QUIT, 0, FALSE);
}

BOOL safeExitExplorer()
{
    return isVista() ? safeExitExplorerVista() : safeExitExplorerXP_2();
}

int main_(int action)
{
    if (action == ACTION_START_IF_NOT_RUNNING)
    {
        if (FindWindow(TEXT(WINDOW_SHELL_TRAY), NULL))
            return RESULT_ALREADY_RUNNING;
    }
    else
    {
        if (!safeExitExplorer())
            return RESULT_ERROR_CANT_EXIT;

        Sleep(EXIT_CHECK_PRE_SLEEP);
        int numCheck = EXIT_CHECK_COUNT;
        for (; numCheck && FindWindow(TEXT(WINDOW_SHELL_TRAY), NULL); --numCheck)
            Sleep(EXIT_CHECK_STEP_SLEEP);
        if (!numCheck)
            return RESULT_ERROR_TOO_LONG_EXIT;        
    }

    if (action != ACTION_EXIT_ONLY) 
    {
        TCHAR path[] = TEXT(SHELL_FILENAME);
        if (!run(path))
            return RESULT_ERROR_CANT_START;
    }

    return RESULT_OK;
}

//BOOL isConsole;
HANDLE hStdOut;

void print(const char *s)
{
    //if (isConsole && hStdOut != INVALID_HANDLE_VALUE)
    //{
        DWORD written;
        WriteConsoleA(hStdOut, s, strlen(s), &written, NULL);
    //}
    //else
    //    MessageBoxA(NULL, s, NULL, MB_OK);  // MB_ICONERROR
}

// #ifdef NOCRT
int WINAPI main()
// #else
// int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
// #endif
{
    int action = ACTION_INVALID;
    int argc;
    BOOL isConsoleMode = FALSE;
    WCHAR **argv = CommandLineToArgvW(GetCommandLineW(), &argc);
    if (argv)
        for(int i = 0; i < argc; i++)
            if (argv[i] && argv[i][0] == '-')
            {
                switch(argv[i][1])
                {                    
                    case 'c': isConsoleMode = TRUE; break;
                    
                    case 'r': action = ACTION_RESTART; break;
                    case 'e': action = ACTION_EXIT_ONLY; break;
                    case 's': action = ACTION_START_IF_NOT_RUNNING; break;
                };
                if (action != ACTION_INVALID)
                    break;
            }
   
    //if (isConsoleMode)
    //{
    //    isConsole = AttachConsole((DWORD)-1) || AllocConsole();    
        hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
    //}
    
    if (ACTION_INVALID == action)
    {
        print(USAGE);
        return 0;
    }

    int result = main_(action);
    if (result != RESULT_OK)        
        print(MESSAGE[result]);
    
    //if (isConsoleMode)
    //    FreeConsole();
    ExitProcess(result);
    return result;
}
