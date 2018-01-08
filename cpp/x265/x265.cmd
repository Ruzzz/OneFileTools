:: PARAMS
set __IN_DIR__=d:\Libs\dist\x265
set __OUT_DIR__=d:\Libs\bin\x265
set __PLATFORM__=x64
set __ASM__=1



:: TODO:
:: - TOOLSET=-T v141_xp
:: - -DWINXP_SUPPORT=ON
set __BUILD_DIR__=vs2017
set __GENERATOR__=Visual Studio 15
set __CMAKE_ASM_PARAM__=-DENABLE_ASSEMBLY=OFF
if "%__PLATFORM__%" == "x32" (
    set __MSBUILD_PLATFORM__=Win32
    set __CL_PLATFORM___=x86
    set __OUT_DIR__=%__OUT_DIR__%_x32
    set __BUILD_DIR__=%__BUILD_DIR__%_x32
) else (
    set __MSBUILD_PLATFORM__=x64
    set __CL_PLATFORM___=amd64
    set __GENERATOR__=%__GENERATOR__% Win64
    set __OUT_DIR__=%__OUT_DIR__%_x64
    set __BUILD_DIR__=%__BUILD_DIR__%_x64
)
if "%__ASM__%" == "1" (
    
    set __CMAKE_ASM_PARAM__=-DENABLE_ASSEMBLY=ON
    set __OUT_DIR__=%__OUT_DIR__%_asm
    set __BUILD_DIR__=%__BUILD_DIR__%_asm
)


:: GET SOURCE
if not exist %__IN_DIR__% hg clone https://bitbucket.org/multicoreware/x265 %__IN_DIR__%
 

set __BUILD_DIR__=%__IN_DIR__%\%__BUILD_DIR__%
if exist %__BUILD_DIR__% rd /q /s %__BUILD_DIR__%
mkdir %__BUILD_DIR__%
pushd %__BUILD_DIR__%
cmake -G "%__GENERATOR__%" %__TOOLSET__% ../source %__CMAKE_ASM_PARAM__% -DSTATIC_LINK_CRT=ON -DENABLE_PIC=ON
popd


:: RUN VC++ ENV
if not exist "%VS150COMNTOOLS%" (
    echo Specify environment variable VS150COMNTOOLS
    echo https://gist.github.com/Ruzzz/754abea012dc9e5825e33ff3ccb67296
    goto :EOF
)
call "%VS150COMNTOOLS%\..\..\VC\Auxiliary\Build\vcvarsall.bat" %__CL_PLATFORM___%


:: COMPILE
pushd %__BUILD_DIR__%
MSBuild /property:Configuration="Release" x265.sln /target:x265-static /p:Platform=%__MSBUILD_PLATFORM__%
popd


:: TODO: copy Include and Lib

pause