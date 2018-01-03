:: DEPS:
:: - Install https://msys2.github.io
::   - Add to PATH: %MSYS2_ROOT%\usr\bin\
::   - Update:
::     - pacman.exe -Syu
::     - pacman.exe -Su
::     - pacman.exe -S pkg-config make diffutils
::     - pacman.exe -Rs nasm
:: - Install and add to path: http://www.nasm.us/


:: PARAMS
set IN_DIR=d:/Libs/dist/x264
set OUT_DIR=d:/Libs/bin/x264
set PLATFORM=x64
set ASM=1

if "%PLATFORM%" == "x32" (
    set CL_PLATFORM_=x86
    set MINGW_PLATFORM_=MINGW32
    set OUT_DIR=%OUT_DIR%_x32
) else (
    set CL_PLATFORM_=amd64
    set MINGW_PLATFORM_=MINGW64
    set OUT_DIR=%OUT_DIR%_x64
)
if "%ASM%" == "1" (
    set ASM_=--asm
    set OUT_DIR=%OUT_DIR%_asm
)


:: GET SOURCE
if not exist %IN_DIR% git clone --depth=1 http://git.videolan.org/git/x264.git %IN_DIR%


:: PREPARE OUTPUT DIR
if not exist %OUT_DIR% mkdir %OUT_DIR%
if exist %OUT_DIR%/lib     rmdir /s /q %OUT_DIR%/lib
if exist %OUT_DIR%/include rmdir /s /q %OUT_DIR%/include


:: RUN VC++ ENV
:: VS150COMNTOOLS_fix_as_admin.cmd 
:: https://gist.github.com/Ruzzz/754abea012dc9e5825e33ff3ccb67296
if not exist "%VS150COMNTOOLS%" (
    echo Specify environment variable VS150COMNTOOLS
    goto :EOF
)
call "%VS150COMNTOOLS%\..\..\VC\Auxiliary\Build\vcvarsall.bat" %CL_PLATFORM_%


:: RUN MSYS2 ENV
if not exist "%MSYS2_ROOT%" (
    echo Specify environment variable MSYS2_ROOT
    goto :EOF
)
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=enabled_from_arguments
set MSYSTEM=%MINGW_PLATFORM_%


:: COMPILE
bash.exe --login -x %~dpn0.sh %ASM_% --in %IN_DIR% --out %OUT_DIR%
pause


:: Set as admin
:: setx X264_LIB_ROOT "PATH\%OUT_DIR%\" /M