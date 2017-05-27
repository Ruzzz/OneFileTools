::   _ __ _   _ ____________
::  | '__| | | |_  /_  /_  /
::  | |  | |_| |/ / / / / /
::  |_|   \__,_/___/___/___|
::
:: Prepare WinBoot drive
:: Usage: this.cmd [drive_letter]
:: Note: Run as Admin
:: Do:
:: - Set Active
:: - Format
:: - Prepare MBR and PBR
:: - Copy all to drive from current dir ./files
::
:: Mail:    ruzzzua@gmail.com
:: Version: 2016-11-21

@setlocal
@echo off
set DRIVE=%1
if "%DRIVE%."=="." set /p DRIVE="Drive letter: "
if not exist %DRIVE%:\ (
    echo ERROR: Invalid drive letter
    exit /b 1
)

echo Set Active
echo Format
(
    echo select volume %DRIVE%
    echo active
    echo format fs=ntfs label=WINBOOT quick
)|diskpart >nul
:: format %DRIVE%: /fs:ntfs /q /v:BOOT
:: if errorlevel 1 exit /b 1
echo Prepare MBR and PBR
bootsect /nt60 %DRIVE%: /mbr >nul
if exist ".\files" (
    echo Copy files
    xcopy ".\files" %DRIVE%:\ /q /y /e /h >nul
)
endlocal
