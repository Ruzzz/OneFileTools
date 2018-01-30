set __IN_DIR__=%DEV_LIBS_DISTR%\Qt\qt-everywhere-src-5.10.0
set __OUT_DIR__=%DEV_LIBS%\Qt\Qt5.10.0\msvc2017_64_static
set __PLATFORM__=x64

if "%__PLATFORM__%" == "x32" (
    set __CL_PLATFORM___=x86
) else (
    set __CL_PLATFORM___=amd64
)

:: RUN VC++ ENV
if not exist "%VS150COMNTOOLS%" (
    echo Specify environment variable VS150COMNTOOLS
    echo https://gist.github.com/Ruzzz/754abea012dc9e5825e33ff3ccb67296
    goto :EOF
)
call "%VS150COMNTOOLS%\..\..\VC\Auxiliary\Build\vcvarsall.bat" %__CL_PLATFORM___%

%__IN_DIR__%\configure.bat ^
    -static ^
    -static-runtime ^
    -platform win32-msvc2017 -mp ^
    -prefix %__OUT_DIR__% ^
    -debug-and-release ^
    -opensource ^
    -confirm-license ^
    -recheck-all ^
    -make libs ^
    -qt-zlib ^
    -qt-pcre ^
    -qt-libpng ^
    -qt-libjpeg ^
    -qt-freetype ^
    -sql-sqlite ^
    -qt-sqlite ^
    -combined-angle-lib ^
    -nomake examples ^
    -nomake tests ^
    -nomake tools ^    
    -no-openssl ^
    -no-dbus ^
    -skip qtconnectivity ^
    -skip qtdeclarative ^
    -skip qtgamepad ^
    -skip qtlocation ^
    -skip qtpurchasing ^
    -skip qtquickcontrols ^
    -skip qtquickcontrols2 ^
    -skip qtsensors ^
    -skip qttools ^
    -skip qtwebsockets ^
    -skip qtwinextras ^
    -skip qtwebchannel ^
    -skip qtwebengine ^
    -skip qtwebkit ^
    -skip qtwebkit-examples

nmake
nmake install
    
pause