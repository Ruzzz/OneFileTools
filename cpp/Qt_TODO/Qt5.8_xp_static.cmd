:: http://doc.qt.io/qt-5/windows-building.html
:: http://doc.qt.io/qt-5/configure-options.html
:: http://doc.qt.io/qt-4.8/ssl.html
:: configure -h || qtbase\config_help.txt


::
:: INIT XP TOOLCHAIN
::


:: goto :SKIP_XP
set SDK71PATH=%ProgramFiles%\Microsoft SDKs\Windows\7.1A
path %SDK71PATH%\Bin;%PATH%
set INCLUDE=%INCLUDE%;%SDK71PATH%\Include
set LIB=%LIB%;%SDK71PATH%\Lib
:SKIP_XP


::
:: INIT VS2015
::


:: VS140COMNTOOLS_in_VS2017_fix.reg
:: https://gist.github.com/Ruzzz/38dc70f4b850dd5e379f8cfa2cbf09a3
if not exist "%VS140COMNTOOLS%\..\..\VC\bin\vcvars32.bat" goto :ERROR
call "%VS140COMNTOOLS%\..\..\VC\bin\vcvars32.bat"


::
:: INIT QT
::


set __OPENSSL_PATH__=c:\Dev\OpenSSL_102l_vs2015_32_xp
set _SOURCE_ROOT=%~dp0
set PATH=%_SOURCE_ROOT%\qtbase\bin;%_SOURCE_ROOT%\gnuwin32\bin;%PATH%
set QMAKESPEC=win32-msvc2015
set _SOURCE_ROOT=

set PATH=%__OPENSSL_PATH__%\bin\;%PATH%
:: -lGdi32 for error: 
:: libeay32.lib(rand_win.obj) : error LNK2001: unresolved external symbol __imp__CreateCompatibleBitmap@12
:: libeay32.lib(rand_win.obj) : error LNK2001: unresolved external symbol __imp__DeleteObject@4
:: libeay32.lib(rand_win.obj) : error LNK2001: unresolved external symbol __imp__GetDeviceCaps@8
:: libeay32.lib(rand_win.obj) : error LNK2001: unresolved external symbol __imp__GetDIBits@28
:: libeay32.lib(rand_win.obj) : error LNK2001: unresolved external symbol __imp__GetObjectA@12
set OPENSSL_LIBS=-llibeay32 -lssleay32 -lgdi32
set INCLUDE=%INCLUDE%;%__OPENSSL_PATH__%\include\;%__OPENSSL_PATH__%\include\openssl\
set LIB=%LIB%;%__OPENSSL_PATH__%\lib\
set LIBPATH=%LIBPATH%;%__OPENSSL_PATH__%\lib\


::
:: --- MAIN ---
::


:: MAYBE (UN)COMMENT STEP-BY-STEP
::goto :CONFIG
goto :BUILD
goto :EOF


::
:: CONFIG
::


:CONFIG
:: TODO -no-opengl -no-angle -no-icu
:: -recheck
configure.bat ^
        -opensource ^
        -confirm-license ^
        -prefix d:\AppDataBig\qt5.8_32_xp\ ^
        -platform win32-msvc2015 ^
        -debug-and-release ^
        -static ^
        -sse2 ^
        -static-runtime ^
        -ltcg ^
        -mp ^
        -ssl ^
        -openssl-linked ^
        OPENSSL_LIBS="-llibeay32 -lssleay32 -lgdi32" ^
        -I %__OPENSSL_PATH__%\include\openssl\ ^
        -I %__OPENSSL_PATH__%\include\ ^
        -L %__OPENSSL_PATH__%\lib\ ^
        -nomake libs ^
        -nomake tools ^
        -nomake examples ^
        -nomake tests ^        
        -skip qtwebengine
goto :EOF


::
:: BUILD
::


:BUILD
nmake install
goto :EOF


:ERROR
pause