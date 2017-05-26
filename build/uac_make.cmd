@echo off
setlocal
:: Gen: gen_vc.cmd -nocrt -xp ..\src\mcrt.c ..\src\uac.c -link /out:..\bin\uac.exe
:: Init XP ToolChain
set SDK71PATH=%ProgramFiles%\Microsoft SDKs\Windows\7.1A
path %SDK71PATH%\Bin;%PATH%
set INCLUDE=%INCLUDE%;%SDK71PATH%\Include
set LIB=%LIB%;%SDK71PATH%\Lib

:: Build
:: VS150COMNTOOLS_fix.cmd
:: https://gist.github.com/Ruzzz/754abea012dc9e5825e33ff3ccb67296
call "%VS150COMNTOOLS%\..\..\VC\Auxiliary\Build\vcvarsall.bat" x86
if ERRORLEVEL 1 goto :ERROR
set CL=/W4 /MT /GF /D NDEBUG /D WIN32 /D _WINDOWS /D _UNICODE /D UNICODE /O1 /GS- /EHsa- /D NOCRT /GL /D_USING_V110_SDK71_
set LINK=/OPT:REF /OPT:ICF /MACHINE:X86 /DYNAMICBASE:NO /NXCOMPAT:NO /FIXED /NODEFAULTLIB /MERGE:.rdata=.text /ENTRY:main /LTCG /SUBSYSTEM:WINDOWS,5.01
cl.exe /nologo kernel32.lib user32.lib shell32.lib advapi32.lib ole32.lib ..\src\mcrt.c ..\src\uac.c /link /nologo /out:..\bin\uac.exe
if ERRORLEVEL 1 goto :ERROR
del *.obj>nul
endlocal
exit 0

:ERROR
endlocal
set ERRORLEVEL=%ERRORLEVEL%
pause
del *.obj>nul
exit %ERRORLEVEL%
