if exist "%VS150COMNTOOLS%" goto :EOF

:: Build Tools
if not exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\BuildTools" goto :VS2017_COMMUNITY
setx /M VS150COMNTOOLS "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\BuildTools\Common7\Tools\\"
goto :EOF

:: Community
:VS2017_COMMUNITY
if not exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community" goto :VS2017_PROFESSIONAL
setx /M VS150COMNTOOLS "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community\Common7\Tools\\"
goto :EOF

:: Professional
:VS2017_PROFESSIONAL
if not exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Professional" goto :VS2017_ENTERPRISE
setx /M VS150COMNTOOLS "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Professional\Common7\Tools\\"
goto :EOF

:: Enterprise
:VS2017_ENTERPRISE
if not exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Enterprise" goto :ERROR_NOT_FOUND
setx /M VS150COMNTOOLS "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Enterprise\Common7\Tools\\"
goto :EOF

:ERROR_NOT_FOUND
echo Not found
pause
