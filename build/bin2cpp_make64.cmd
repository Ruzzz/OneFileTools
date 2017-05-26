@echo off
setlocal
:: Gen: gen_vc.cmd -con -xp ..\src\bin2cpp.cpp -x64 -link /out:..\bin\bin2cpp64.exe
:: Init XP ToolChain
set SDK71PATH=%ProgramFiles%\Microsoft SDKs\Windows\7.1A
path %SDK71PATH%\Bin\x64;%PATH%
set INCLUDE=%INCLUDE%;%SDK71PATH%\Include
set LIB=%LIB%;%SDK71PATH%\Lib\x64

:: Build
:: VS150COMNTOOLS_fix.cmd
:: https://gist.github.com/Ruzzz/754abea012dc9e5825e33ff3ccb67296
call "%VS150COMNTOOLS%\..\..\VC\Auxiliary\Build\vcvarsall.bat" x64
if ERRORLEVEL 1 goto :ERROR
set CL=/W4 /MT /GF /D NDEBUG /D WIN32 /D _WINDOWS /D _UNICODE /D UNICODE /O2 /GL /GS /EHsc  /D_USING_V110_SDK71_
set LINK=/OPT:REF /OPT:ICF /MACHINE:X64 /LTCG /DYNAMICBASE /NXCOMPAT /SUBSYSTEM:CONSOLE,5.02
cl.exe /nologo kernel32.lib user32.lib shell32.lib advapi32.lib ole32.lib ..\src\bin2cpp.cpp /link /nologo /out:..\bin\bin2cpp64.exe
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
