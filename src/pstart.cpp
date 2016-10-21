/// Author: Zaporojets Ruslan
/// Email:  ruzzzua[]gmail.com
/// Date:   2016-10-13

// TODO:
//   - add -wait key

#include <windows.h>
// #include <shlwapi.h> // PathUnExpandEnvStrings
#include <tchar.h>
#include <cstring> // strchr
#include <cwchar>  // wcschr
#include <string>
#include <vector>

#pragma comment(lib,"kernel32.lib")
#pragma comment(lib,"user32.lib")
#pragma comment(lib,"shell32.lib")

//
//  Utils
//

std::string formatSysErrorA(DWORD code, DWORD lang = LANG_NEUTRAL)
{
	char *p;
	DWORD l = ::FormatMessageA(FORMAT_MESSAGE_ALLOCATE_BUFFER |
		FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, NULL,
		code, MAKELANGID(lang, SUBLANG_DEFAULT),
		reinterpret_cast<LPSTR>(&p), 0, NULL);
	if (p && l)
	{
		char *t = ::strchr(p, '\r');
		if (t)
			*t = '\0';
		// std::string result(p, p + static_cast<size_t>(l));
		std::string result(p);
		::LocalFree(p);
		return result;
	}
	else
		return std::string();
}

std::wstring formatSysErrorW(DWORD code, DWORD lang = LANG_NEUTRAL)
{
	wchar_t *p;
	DWORD l = ::FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER |
		FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, NULL,
		code, MAKELANGID(lang, SUBLANG_DEFAULT),
		reinterpret_cast<LPWSTR>(&p), 0, NULL);
	if (p && l)
	{
		wchar_t *t = ::wcschr(p, '\r');
		if (t)
			*t = '\0';
		// std::wstring result(p, p + static_cast<size_t>(l));
		std::wstring result(p);
		::LocalFree(p);
		return result;
	}
	else
		return std::wstring();
}

// Return process handle
HANDLE runProcessW(const std::wstring &path)
{
	std::wstring p(path);
	STARTUPINFO si = { 0 };
	si.cb = sizeof(si);
	PROCESS_INFORMATION pi = { 0 };

	if (!::CreateProcessW(NULL, &p[0], NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi))
		return NULL;
	::CloseHandle(pi.hThread);
	return pi.hProcess;
}

// Return process handle
HANDLE runShell(const wchar_t *path)
{
	SHELLEXECUTEINFOW sei = { 0 };
	sei.cbSize = sizeof(SHELLEXECUTEINFOW);
	sei.fMask = SEE_MASK_NOCLOSEPROCESS | SEE_MASK_FLAG_NO_UI;
	sei.lpFile = path;
	sei.nShow = SW_SHOW;
	return ::ShellExecuteExW(&sei) ? sei.hProcess : NULL;
}

// if false then 'value' undefined
bool getEnvVarA(const char *name, std::string &value)
{
	value.resize(1024);
	bool getting = true;
	while (getting)
	{
		DWORD size = ::GetEnvironmentVariableA(name, &value[0], value.length());
		if (::GetLastError() == ERROR_ENVVAR_NOT_FOUND || 0 == size)
			return false;
		getting = size > value.length();
		value.resize(static_cast<std::size_t>(size));
	};
	return true;
}

// if false then 'value' undefined
bool getEnvVarW(const wchar_t *name, std::wstring &value)
{
	value.resize(1024);
	bool getting = true;
	while (getting)
	{
		// Передавая размер буфера, учитываем \0.
		DWORD size = ::GetEnvironmentVariableW(name, &value[0], value.length());
		if (::GetLastError() == ERROR_ENVVAR_NOT_FOUND || 0 == size)
			return false;
		// Если наш буфер маленький:
		//   Вернет размер учитывая \0.
		//   Нужно увеличить буфер до size.
		// Если все ок:
		//   Вернет размер НЕ учитывая \0.
		//   Нужно уменьшить буфер до size.
		// assert (size <> value.length())
		getting = size > value.length();
		value.resize(static_cast<std::size_t>(size));
	};
	return true;
}

bool expandEnvsA(std::string &value)
{
	std::string buf;
	buf.resize(MAX_PATH + 2); // +1 для ExpandEnvironmentStringsA.
	bool getting = true;
	while (getting)
	{
		// Передавая размер буфера, учитываем \0.
		//   И +1 для ExpandEnvironmentStringsA.
		DWORD size = ::ExpandEnvironmentStringsA(value.c_str(), &buf[0], buf.length());
		if (0 == size)
			return false;
		getting = size > buf.length() - 1;
		if (getting)
			// Если наш буфер маленький:
			//   Вернет размер не известно учитывая ли \0,
			//   так что на всякий случай +1 для \0.
			//   И +1 для ExpandEnvironmentStringsA           
			buf.resize(static_cast<std::size_t>(size + 2));
		else
			// Если все ок:
			//   Вернет размер учитывая \0 
			//   Нужно уменьшить буфер до size - 1.            
			buf.resize(static_cast<std::size_t>(size - 1));
	};
	value.swap(buf);
	return true;
}

bool expandEnvsW(std::wstring &value)
{
	std::wstring buf;
	buf.resize(MAX_PATH + 1);
	bool getting = true;
	while (getting)
	{
		// Передавая размер буфера, учитываем \0
		DWORD size = ::ExpandEnvironmentStringsW(value.c_str(), &buf[0], buf.length());
		if (0 == size)
			return false;
		getting = size > buf.length();
		if (getting)
			// Если наш буфер маленький:
			//   Вернет размер не известно учитывая ли \0,
			//   так что на всякий случай +1 для \0.
			buf.resize(static_cast<std::size_t>(size + 1));
		else
			// Если все ок:
			//   Вернет размер учитывая \0.
			//   Нужно уменьшить буфер до size - 1.
			buf.resize(static_cast<std::size_t>(size - 1));
	};
	value.swap(buf);
	return true;
}

//
//  Main
//

enum
{
	RESULT_OK = 0,
	RESULT_USAGE,
	RESULT_ERROR_CANT_RUN_TARGET
};

const wchar_t *MESSAGE[] =
{
	0,
	L"Add dirs to env var path, run target.exe, wait.\n\n"
    L"Usage: pstart.exe [dir1] [dir2] [..] target.exe",
    
	L"Cant run target exe."
};

int runTarget(const std::wstring &targetPath, const std::vector<std::wstring> &paths)
{
	std::wstring envPathOld;
	if (!getEnvVarW(L"path", envPathOld))
		envPathOld.clear();

	std::wstring envPathNew;
	for (auto &path : paths)
	{
		std::wstring p(path);
		expandEnvsW(p);
		if (!envPathNew.empty())
			envPathNew.push_back(L';');
		envPathNew.append(p);
	}

	if (!envPathOld.empty())
	{
		if (!envPathNew.empty() && envPathOld[0] != L';')
			envPathNew.push_back(L';');
		envPathNew.append(envPathOld);
	}

	::SetEnvironmentVariableW(L"path", envPathNew.c_str());

	std::wstring targetPath_(targetPath);
	expandEnvsW(targetPath_);
	targetPath_ = L'"' + targetPath_ + L'"';
	HANDLE hProcess = runProcessW(targetPath_);
	if (!hProcess)
		return RESULT_ERROR_CANT_RUN_TARGET;
	::WaitForSingleObject(hProcess, INFINITE);
	::CloseHandle(hProcess);

	return RESULT_OK;
}

int APIENTRY _tWinMain(HINSTANCE hInstance,
	HINSTANCE hPrevInstance,
	LPTSTR lpCmdLine,
	int nCmdShow)
{
	UNREFERENCED_PARAMETER(hInstance);
	UNREFERENCED_PARAMETER(hPrevInstance);
	UNREFERENCED_PARAMETER(lpCmdLine);
	UNREFERENCED_PARAMETER(nCmdShow);

	if (__argc < 2)
	{
		::MessageBoxW(NULL, MESSAGE[RESULT_USAGE], L"Error", MB_OK | MB_ICONERROR);
		return RESULT_USAGE;
	}

	std::wstring exe(__targv[__argc - 1]);
	std::vector<std::wstring> paths(__targv + 1, __targv + (__argc - 1));

	int result = runTarget(exe, paths);
	if (result != RESULT_OK)
		::MessageBoxW(NULL, MESSAGE[result], L"Error", MB_OK | MB_ICONERROR);
	return result;
}
