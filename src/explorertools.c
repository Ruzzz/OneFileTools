// Author: Zaporojets Ruslan
// Email:  ruzzzua[]gmail.com
// Date:   2015-09-03

#include <windows.h>
#include "mcrt.h"

#define WINDOW_PROGMAN        "Progman"
#define WINDOW_SHELL_TRAY     "Shell_TrayWnd"
#define SHELL_FILENAME        "explorer.exe"
#define EXIT_CHECK_PRE_SLEEP  1000
#define EXIT_CHECK_COUNT      100
#define EXIT_CHECK_STEP_SLEEP 100

const TCHAR USAGE[] =
{
    TEXT("ExplorerTools v1.0 by Ruslan Zaporojets\n")
    TEXT("Usage: explorertools.exe -r|-e|-s\n")
    TEXT("\n")
    TEXT("Actions:\n")
    TEXT("  -r                 - Safe restart.\n")
    TEXT("  -e                 - Safe exit only.\n")
    TEXT("  -s                 - If not running then start.\n")
};

enum
{
    E_OK = 0,
    E_CANT_EXIT,
    E_TOO_LONG_EXIT,
    E_CANT_START,
    E_ALREADY_RUNNING
};

enum
{
    ACTION_INVALID = 0,
    ACTION_RESTART = 1,
    ACTION_EXIT_ONLY,
    ACTION_START_IF_NOT_RUNNING
};

const TCHAR *MESSAGE[] =
{
    TEXT("OK"),
    TEXT("Explorer cannot exit!"),
    TEXT("Explorer is too long exit!"),
    TEXT("Explorer cannot start!"),
    TEXT("Explorer already running!")
};

HANDLE hStdOut;

void print(const TCHAR *s)
{
    DWORD written;
    WriteConsole(hStdOut, s, (DWORD)tcslen(s), &written, NULL);
}

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

int core(int action)
{
    if (action == ACTION_START_IF_NOT_RUNNING)
    {
        if (FindWindow(TEXT(WINDOW_SHELL_TRAY), NULL))
            return E_ALREADY_RUNNING;
    }
    else
    {
        if (!safeExitExplorer())
            return E_CANT_EXIT;

        Sleep(EXIT_CHECK_PRE_SLEEP);
        int numCheck = EXIT_CHECK_COUNT;
        for (; numCheck && FindWindow(TEXT(WINDOW_SHELL_TRAY), NULL); --numCheck)
            Sleep(EXIT_CHECK_STEP_SLEEP);
        if (!numCheck)
            return E_TOO_LONG_EXIT;
    }

    if (action != ACTION_EXIT_ONLY)
    {
        HANDLE hProcess = runProcess(TEXT(SHELL_FILENAME));
        if (!hProcess)
            return E_CANT_START;
        else
            CloseHandle(hProcess);
    }

    return E_OK;
}

int WINAPI main()
{
    int action = ACTION_INVALID;
    const TCHAR *cl = GetCommandLine();
    cl = commandLineSkipExePath(cl);
    if (cl && *cl)
    {
        if (*cl && (*cl == '-') && (*(++cl)))
        {
            switch (*cl)
            {
                case 'r': action = ACTION_RESTART; break;
                case 'e': action = ACTION_EXIT_ONLY; break;
                case 's': action = ACTION_START_IF_NOT_RUNNING; break;
            };
        }
    }

    hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
    if (ACTION_INVALID == action)
    {
        print(USAGE);
        ExitProcess(1);
    }

    print(isVista() ? TEXT("Vista method: ") : TEXT("XP method: "));
    int result = core(action);
    if (result != E_OK)
        print(TEXT("ERROR "));
    print(MESSAGE[result]);
    print(TEXT("\n"));

    ExitProcess(result);
}