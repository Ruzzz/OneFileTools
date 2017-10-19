@echo off

if "%~1"=="" (
    echo ERROR: No Parameters
    pause
    goto :EOF
)

:LOOP
echo.
echo ------------------------------
echo Process: %1
echo ------------------------------
@echo on

takeown /r /skipsl /f %1

@echo off
if not %ERRORLEVEL%==0 (
    echo Error Code %ERRORLEVEL% for %1
    pause
    goto :EOF
)
shift
if "%~1"=="" goto :EOF
goto :LOOP
