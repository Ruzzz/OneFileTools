:: Usage: this.bat FILE [FILE ...]
:: Or copy to %AppData%\Microsoft\Windows\SendTo\
:: Dependences: ffmpeg

@echo off
if (%1)==() goto :NO_PARAMETER

:LOOP
ffmpeg -i %1 -bsf:a aac_adtstoasc -c:a copy "%~dpn1_%date%_%random%.m4a"
shift
if (%1)==() goto :EOF
goto :LOOP

:NO_PARAMETER
echo Usage:
echo this.bat FILE [FILE ...]
pause
