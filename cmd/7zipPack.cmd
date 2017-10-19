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

7za a -y -t7z -mx9 -mhe=on -mtc=on -m0=LZMA2 "%~f1.7z" %1

@echo off
if not %ERRORLEVEL%==0 (
    echo Error Code %ERRORLEVEL% for %1
    pause
    goto :EOF
)
shift
if "%~1"=="" goto :EOF
goto :LOOP
