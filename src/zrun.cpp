// Author: Ruslan Zaporojets
// Email:  ruzzzua[]gmail.com
// Date:   2016-10-13
//
// TODO:
//   - add -wait key

#include <iostream>
#include <string>
#include <vector>
#include <cstring> // strchr
#include <cwchar>  // wcschr

#include <io.h>     // _setmode, _fileno
#include <fcntl.h>  // _O_U8TEXT

#include <windows.h>
// #include <shlwapi.h> // TODO: PathUnExpandEnvStrings
#include <tchar.h>
#include <objbase.h>

namespace impl {

template <typename Cont, typename Char, typename Fn>
Cont expandEnvs(const Char *value, Fn fn)
{
    Cont ret;
    ret.resize(MAX_PATH);
    DWORD size = fn(value, &ret[0], static_cast<DWORD>(ret.size()));
    if (!size)
    {
        ret.clear();
        return ret;
    } 
    else if (size > ret.size())
    {
        ret.resize(static_cast<std::size_t>(size));
        size = fn(value, &ret[0], static_cast<DWORD>(ret.size()));
    }
    ret.resize(static_cast<std::size_t>(size - 1));
    return ret;
}

template <typename Cont, typename Char, typename Fn>
Cont getEnvVar(const Char *name, Fn fn)
{
    Cont ret;
    ret.resize(MAX_PATH);
    DWORD size = fn(name, &ret[0], static_cast<DWORD>(ret.size()));
    if (::GetLastError() == ERROR_ENVVAR_NOT_FOUND || 0 == size)
    {
        ret.clear();
        return ret;
    }
    bool rep = size > ret.size();
    ret.resize(static_cast<std::size_t>(size));
    if (rep)
    {
        size = fn(name, &ret[0], static_cast<DWORD>(ret.size()));
        ret.resize(static_cast<std::size_t>(size));
    }
    return ret;
}

template <typename StartupInfo, typename Char, typename Fn>
HANDLE runProcess(const Char *path, Fn fn, WORD cmdShow = SW_SHOWNORMAL)
{
    std::basic_string<Char> p(path);
    StartupInfo si = { 0 };
    si.cb = sizeof(si);
    si.dwFlags = STARTF_USESHOWWINDOW;
    si.wShowWindow = cmdShow;
    PROCESS_INFORMATION pi = { 0 };
    DWORD flags = CREATE_DEFAULT_ERROR_MODE;
#ifdef _UNICODE
    flags ^= CREATE_UNICODE_ENVIRONMENT;
#endif
    if (!fn(nullptr, &p[0], nullptr, nullptr, FALSE, flags, nullptr, nullptr,
            &si, &pi))
        return nullptr;
    ::CloseHandle(pi.hThread);
    return pi.hProcess;
}

struct CoHolder
{
    CoHolder() : ok(S_OK == ::CoInitializeEx(nullptr,
        COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE)) { }
    ~CoHolder() { if (ok) ::CoUninitialize(); }
private:
    bool ok;
};

template <typename ShellExecuteInfo, typename Char, typename Fn>
HANDLE runShell(
    const Char *op,
    const Char *path,
    const Char *params,
    const Char *dir,
    HWND wnd,
    Fn fn,
    WORD cmdShow = SW_SHOWNORMAL)
{
    CoHolder coh;
    ShellExecuteInfo sei = { 0 };
    sei.cbSize = sizeof(sei);
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
    return fn(&sei) != FALSE ? sei.hProcess : nullptr;
}

} // namespace impl

inline std::string expandEnvs(const char *value)
{
    return impl::expandEnvs<std::string>(value, ::ExpandEnvironmentStringsA);
}

inline std::wstring expandEnvs(const wchar_t *value)
{
    return impl::expandEnvs<std::wstring>(value, ::ExpandEnvironmentStringsW);
}

inline std::string getEnvVar(const char *name)
{
    return impl::getEnvVar<std::string>(name, ::GetEnvironmentVariableA);
}

inline std::wstring getEnvVar(const wchar_t *name)
{
    return impl::getEnvVar<std::wstring>(name, ::GetEnvironmentVariableW);
}

inline HANDLE runProcess(const char *path, WORD cmdShow = SW_SHOWNORMAL)
{
    return impl::runProcess<STARTUPINFOA>(path, ::CreateProcessA, cmdShow);
}

inline HANDLE runProcess(const wchar_t *path, WORD cmdShow = SW_SHOWNORMAL)
{
    return impl::runProcess<STARTUPINFOW>(path, ::CreateProcessW, cmdShow);
}

inline HANDLE runShell(
    const char *op,
    const char *path,
    const char *params = nullptr,
    const char *dir = nullptr,
    HWND wnd = nullptr,
    WORD cmdShow = SW_SHOWNORMAL)
{
    return impl::runShell<SHELLEXECUTEINFOA>(op, path, params, dir, wnd,
        ::ShellExecuteExA, cmdShow);
}

inline HANDLE runShell(
    const wchar_t *op,
    const wchar_t *path,
    const wchar_t *params = nullptr,
    const wchar_t *dir = nullptr,
    HWND wnd = nullptr,
    WORD cmdShow = SW_SHOWNORMAL)
{
    return impl::runShell<SHELLEXECUTEINFOW>(op, path, params, dir, wnd,
        ::ShellExecuteExW, cmdShow);
}

bool isElevated()
{
    bool ret = false;
    HANDLE hToken = nullptr;
    if (::OpenProcessToken(::GetCurrentProcess(), TOKEN_QUERY, &hToken))
    {
        TOKEN_ELEVATION elevation;
        DWORD size = sizeof(TOKEN_ELEVATION);
        if (::GetTokenInformation(hToken, TokenElevation, &elevation,
                sizeof(elevation), &size))
            ret = elevation.TokenIsElevated != 0;
    }
    if (hToken)
        ::CloseHandle(hToken);
    return ret;
}

template <typename Char>
const Char* commandLineSkipExePath(const Char *s)
{
    if (!s)
        return s;
    if ('"' == *s)
    {
        ++s;
        for (; *s && *s != '"'; ++s);
        if ('"' == *s)
            ++s;
    }
    else
        for (; *s > ' '; ++s);
    for (; *s && *s <= ' '; ++s);
    return s;
}

const wchar_t USAGE[] =
{
    L"zrun v1.0 by Ruslan Zaporojets\n"
    L"Usage: zrun.exe [-path PATH] [-uac] [-wait] [-hide] CMD\n"
};

enum Result
{
    E_OK         = 0,
    E_UNKNOWN    = -1,
    E_MYCODE     = -2,
    E_CANNOT_RUN = -3,
    E_CANNOT_UAC = -4
};

const wchar_t *RESULT[] =
{
    L"",
    L"Unknown error: ",
    L"Target used zrun's exit code: ",
    L"Cannot run: ",
    L"Cannot elevate: "
};

inline bool validResultIndex(int index)
{
    return (index > 0) && (index < _countof(RESULT));
}

struct AppOptions
{
    std::wstring target;
    std::vector<std::wstring> paths;
    bool uac = false;
    bool wait = false;
    bool hide = false;
};

int targetCode(bool me, bool wait, HANDLE hProcess, int errorCode)
{
    if (!hProcess)
        return errorCode;
    if (wait)
    {
        ::WaitForSingleObject(hProcess, INFINITE);
        DWORD pcode = 0;
        bool ok = ::GetExitCodeProcess(hProcess, &pcode) != FALSE;
        ::CloseHandle(hProcess);
        if (!ok)
            return (int)Result::E_UNKNOWN;
        if (!me && validResultIndex(-((int)pcode)))
            return (int)Result::E_MYCODE;
        // TODO: Use user env var ZRUN_TARGET_CODE
        return (int)pcode;
    }
    else
    {
        ::CloseHandle(hProcess);
        return Result::E_OK;
    }
}

int run(const AppOptions &opts)
{
    std::wstring oldEnvPath = getEnvVar(L"path");
    std::wstring newEnvPath;

    for (const auto &path : opts.paths)
    {
        std::wstring p(expandEnvs(path.c_str()));
        if (!newEnvPath.empty())
            newEnvPath.push_back(L';');
        newEnvPath.append(p);
    }

    if (!oldEnvPath.empty())
    {
        if (!newEnvPath.empty() && oldEnvPath[0] != L';')
            newEnvPath.push_back(L';');
        newEnvPath.append(oldEnvPath);
    }

    ::SetEnvironmentVariableW(L"path", newEnvPath.c_str());
    std::wstring targetPath_(expandEnvs(opts.target.c_str()));
    HANDLE hProcess = runProcess(targetPath_.c_str(), opts.hide ? SW_HIDE : SW_SHOWNORMAL);
    return targetCode(false, opts.wait, hProcess, (int)Result::E_CANNOT_RUN);
}

int elevate()
{
    const wchar_t *cl = GetCommandLineW();
    cl = commandLineSkipExePath(cl);
    wchar_t exeName[MAX_PATH];
    if (::GetModuleFileNameW(nullptr, exeName, _countof(exeName)) == 0)
        return E_CANNOT_UAC;
    HANDLE hProcess = runShell(L"runas", exeName, cl, nullptr, nullptr, SW_HIDE);
    return targetCode(true, true, hProcess, (int)Result::E_CANNOT_UAC);
}

bool parseOpts(int argc, const wchar_t **argv, AppOptions &opts)
{
    if (argc < 2)
        return false;
    const std::vector<std::wstring> args(argv + 1, argv + argc);
    for (size_t i = 0; i < args.size(); ++i)
    {
        if (args[i] == L"-path")
        {
            if (++i == args.size())
                return false;
            opts.paths.push_back(std::move(args[i]));
        }
        else if (args[i] == L"-uac")
        {
            opts.uac = true;
        }
        else if (args[i] == L"-wait")
        {
            opts.wait = true;
        }
        else if (args[i] == L"-hide")
        {
            opts.hide = true;
        }
        else
        {
            if (!opts.target.empty())
                opts.target.append(1, L' ');
            opts.target += args[i];
        }
    }
    return !opts.target.empty();;
}

int wmain(int argc, const wchar_t** argv)
{
    _setmode(_fileno(stdout), _O_U16TEXT);
    _setmode(_fileno(stdin), _O_U16TEXT);
    std::wcout << std::boolalpha;

    AppOptions opts;
    if (!parseOpts(argc, argv, opts))
    {
        std::wcout << USAGE;
        return 0;
    }
        
    int ret = (opts.uac && !isElevated()) ? elevate() : run(opts);
    if (validResultIndex(-ret))
        std::wcerr << L"[zrun] ERROR: " << RESULT[-ret] << opts.target << '\n';
    return ret;
}