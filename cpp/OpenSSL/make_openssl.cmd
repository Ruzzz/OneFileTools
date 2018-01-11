:: Note:
:: See file: INSTALL
:: See file: INSTALL.W64
:: Note: rename openssl.exe -> openssl64.exe
:: Note: rename libeay32.lib -> libeay64.lib
:: Note: rename ssleay32.lib -> ssleay64.lib


:: PARAMS
set __IN_DIR__=%DEV_LIBS_DISTR%\openssl-OpenSSL_1_0_2l
set __OUT_DIR__=%DEV_LIBS%\OpenSSL
set __PLATFORM__=x32
set __XP__=0
set __OPENSSL_VER__=102l
set __OPENSSL_10x__=1


set __OUT_CONFIG__=%__OUT_DIR__%_%__OPENSSL_VER__%\Config
set __OUT_DIR__=%__OUT_DIR__%_%__OPENSSL_VER__%\%__PLATFORM__%
if (%__PLATFORM__%)==(x64) (
    set __CL_PLATFORM__=amd64
    set __CONFIGURE_PLATFORM__=VC-WIN64A
) else (
    set __CL_PLATFORM__=x86
    set __CONFIGURE_PLATFORM__=VC-WIN32
)


if not (%__XP__%)==(1) goto :AFTER_XP
:: For 1.0.X
:: - Edit: \util\pl\VC-32.pl 
::   1) if ($FLAVOR =~ /WIN64/)  ...  $lflags="/nologo /subsystem:console /opt:ref"
::      /subsystem:console -> /subsystem:console,5.02
::   2) else # Win32  ...  $lflags="/nologo /subsystem:console /opt:ref"
::      /subsystem:console -> /subsystem:console,5.01
::
:: For 1.1.X
:: - Edit: \Configurations\10-main.conf
:: - Replace: /subsystem:console -> /subsystem:console,5.02 or 5.01
::
:: INIT XP TOOLCHAIN
::
set SDK71PATH=%ProgramFiles%\Microsoft SDKs\Windows\7.1A
set INCLUDE=%SDK71PATH%\Include;%INCLUDE%
if (%__PLATFORM__%)==(x64) (
    path %SDK71PATH%\Bin\x64;%PATH%
    set LIB=%SDK71PATH%\Lib\x64;%LIB%
) else (
    path %SDK71PATH%\Bin;%PATH%
    set LIB=%SDK71PATH%\Lib;%LIB%
)
set __XP_DEFS__=_USING_V110_SDK71_
set __OUT_DIR__=%__OUT_DIR__%_xp
:AFTER_XP


::
:: INIT VC++2017
::
:: VS150COMNTOOLS_fix.cmd
:: https://gist.github.com/Ruzzz/754abea012dc9e5825e33ff3ccb67296
call "%VS150COMNTOOLS%\..\..\VC\Auxiliary\Build\vcvarsall.bat" %__CL_PLATFORM__%
:: call "%VS150COMNTOOLS%\VsDevCmd.bat" %__CL_PLATFORM__%
if ERRORLEVEL 1 goto :ERROR


::
:: BUILD
::
:: MAYBE (UN)COMMENT STEP-BY-STEP
pushd %__IN_DIR__%
if not (%__OPENSSL_10x__%)==(1) goto :BUILD_OPENSSL_11x
perl Configure %__CONFIGURE_PLATFORM__% no-shared threads --prefix=%__OUT_DIR__% --openssldir=%__OUT_CONFIG__% -D%__XP_DEFS__%
if ERRORLEVEL 1 goto :ERROR

if (%__PLATFORM__%)==(x64) (
    call ms\do_win64a
    if ERRORLEVEL 1 goto :ERROR
) else (
    call ms\do_ms
    if ERRORLEVEL 1 goto :ERROR
    call ms\do_nasm
    if ERRORLEVEL 1 goto :ERROR    
)
nmake -f ms\nt.mak clean
nmake -f ms\nt.mak
if ERRORLEVEL 1 goto :ERROR
nmake -f ms\nt.mak install
if ERRORLEVEL 1 goto :ERROR
goto :AFTER_BUILD


:BUILD_OPENSSL_11x
perl Configure %__CONFIGURE_PLATFORM__% no-shared -static no-deprecated threads --prefix=%__OUT_DIR__% --openssldir=%__OUT_CONFIG__% -D%__XP_DEFS__%
if ERRORLEVEL 1 goto :ERROR
nmake
if ERRORLEVEL 1 goto :ERROR
nmake install
if ERRORLEVEL 1 goto :ERROR


:AFTER_BUILD
popd
pause
goto :EOF


:ERROR
popd
pause