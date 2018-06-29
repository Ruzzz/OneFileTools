:: Author:  Ruslan Zaporojets
:: Email:   ruzzzua[]gmail.com
:: Date:    2017-10-12
:: Usage:   this.cmd DIR GENERATOR [TOOLSET]
:: Example: this.cmd VS2017x64XP "Visual Studio 15 Win64" v141_xp
if "%1"=="" goto :MY

cd /d "%~dp0"
set BUILD_DIR=build
if not "%3"=="" ( set TOOLSET=-T %3 ) else ( set TOOLSET= )
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
cd "%BUILD_DIR%"
if exist %1 rd /q /s %1
mkdir %1
cd %1
cmake -G %2 %TOOLSET% ../..
:: cmake --build . --clean-first --config release
:: ctest -V -C Release
:: pause
:: cmake --build . --clean-first --config debug
cd ../..
pause
exit

:MY
:: start cmd /C call "%~dpnx0" vs2015x32   "Visual Studio 14""
:: start cmd /C call "%~dpnx0" vs2015x64   "Visual Studio 14 Win64""
:: start cmd /C call "%~dpnx0" vs2015x32xp "Visual Studio 14"       v140_xp
:: start cmd /C call "%~dpnx0" vs2015x64xp "Visual Studio 14 Win64" v140_xp
:: start cmd /C call "%~dpnx0" vs2017x32   "Visual Studio 15"
start cmd /C call "%~dpnx0" vs2017x64   "Visual Studio 15 Win64"
:: start cmd /C call "%~dpnx0" vs2017x32xp "Visual Studio 15"       v141_xp
:: start cmd /C call "%~dpnx0" vs2017x64xp "Visual Studio 15 Win64" v141_xp
:: start cmd /C call "%~dpnx0" gcc         "MinGW Makefiles"