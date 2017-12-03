:: Usage: this.bat FILE [FILE ...]
:: Or copy to %AppData%\Microsoft\Windows\SendTo\
:: Dependences: ffmpeg

@echo off
if (%1)==() goto :NO_PARAMETER

:LOOP
@echo on
ffmpeg -i %1 -bsf:a aac_adtstoasc -vn -c:a copy "%~dpn1_%random%.m4a"
@echo off
if errorlevel 1 goto :ERROR
shift
if (%1)==() goto :EOF
goto :LOOP

:NO_PARAMETER
echo Usage:
echo this.bat FILE [FILE ...]
pause
goto :EOF

:ERROR
pause