@echo off
cd /d "%~dp0"
:: set __NGEN__=1
:: set __NMAKE__=1
:: set __NTEST__=1

if defined __NGEN__ goto :MAKE
set IN=..\src\[APPLICATION].cpp
set OUT=-link /out:..\bin\[APPLICATION]
set OPTS=-con -xp [SPECIFY]
call ..\cmd\gen_vc.cmd %OPTS% %IN% %OUT%.exe>[APPLICATION]_make.cmd || goto :EOF
call ..\cmd\gen_vc.cmd %OPTS% %IN% -x64 %OUT%64.exe>[APPLICATION]_make64.cmd || goto :EOF

:MAKE
if defined __NMAKE__ goto :TEST
if not exist "..\bin" mkdir "..\bin"
cmd /k [APPLICATION]_make.cmd || goto :EOF
cmd /k [APPLICATION]_make64.cmd || goto :EOF

:TEST
if defined __NTEST__ goto :EOF
cls
..\bin\[APPLICATION].exe -target notepad || goto :ERROR
..\bin\[APPLICATION]64.exe -target notepad || goto :ERROR
goto :EOF

:ERROR
pause