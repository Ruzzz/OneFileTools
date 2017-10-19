@echo off
if "%1" NEQ "" goto :run
echo Usage:
echo this.bat update.zip
echo this.bat update.zip 192.168.56.101:5555
goto :eof

:run
if "%2" NEQ "" set host=-s %2
echo adb %host% push %~1 /sdcard/Download/
echo adb %host% shell "/system/bin/flash-archive.sh /sdcard/Download/%~nx1"
echo adb %host% reboot
set host=
pause
