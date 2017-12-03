:: Usage: this.bat FILE [FILE ...]
:: Or copy to %AppData%\Microsoft\Windows\SendTo\
:: Dependences: ffmpeg

@echo off
if (%1)==() goto :NO_PARAMETER

:LOOP
@echo on

ffmpeg -i %1 -bsf:a aac_adtstoasc -c:a copy "%~dpn1_%random%.aac"

@echo off
if not %ERRORLEVEL%==0 (
    echo Error Code %ERRORLEVEL% for %1
    pause
    goto :EOF
)
shift
if (%1)==() goto :EOF
goto :LOOP

:NO_PARAMETER
echo Usage:
echo this.bat FILE [FILE ...]
pause