:: DEPS:
:: - Install https://msys2.github.io
::   - Add to PATH: %MSYS2_ROOT%\usr\bin\
::   - Update:
::     - pacman -Sy pacman
::     - pacman -Syu
::     - pacman -Su
::     - pacman -S pkg-config make diffutils
::     - pacman -Rs nasm
:: - Install and add to path: http://www.nasm.us/


:: PARAMS
set __IN_DIR__=d:/Libs/dist/x264
set __OUT_DIR__=d:/Libs/bin/x264
set __PLATFORM__=x64
set __ASM__=1


if "%__PLATFORM__%" == "x32" (
    set __CL_PLATFORM___=x86
    set __MINGW_PLATFORM___=MINGW32
    set __OUT_DIR__=%__OUT_DIR__%_x32
) else (
    set __CL_PLATFORM___=amd64
    set __MINGW_PLATFORM___=MINGW64
    set __OUT_DIR__=%__OUT_DIR__%_x64
)
if "%__ASM__%" == "1" (
    set __ASM_PARAM__=--asm
    set __OUT_DIR__=%__OUT_DIR__%_asm
)


:: GET SOURCE
if not exist %__IN_DIR__% git clone --depth=1 http://git.videolan.org/git/x264.git %__IN_DIR__%


:: PREPARE OUTPUT DIR
if not exist %__OUT_DIR__% mkdir %__OUT_DIR__%
if exist %__OUT_DIR__%/lib     rmdir /s /q %__OUT_DIR__%/lib
if exist %__OUT_DIR__%/include rmdir /s /q %__OUT_DIR__%/include


:: RUN VC++ ENV
:: VS150COMNTOOLS_fix_as_admin.cmd 
:: https://gist.github.com/Ruzzz/754abea012dc9e5825e33ff3ccb67296
if not exist "%VS150COMNTOOLS%" (
    echo Specify environment variable VS150COMNTOOLS
    goto :EOF
)
call "%VS150COMNTOOLS%\..\..\VC\Auxiliary\Build\vcvarsall.bat" %__CL_PLATFORM___%


:: RUN MSYS2 ENV
if not exist "%MSYS2_ROOT%" (
    echo Specify environment variable MSYS2_ROOT
    goto :EOF
)
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=enabled_from_arguments
set MSYSTEM=%__MINGW_PLATFORM___%


:: COMPILE
bash.exe --login -x %~dpn0.sh %__ASM_PARAM__% --in %__IN_DIR__% --out %__OUT_DIR__%