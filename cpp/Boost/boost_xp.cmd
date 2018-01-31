:: MS VC++
:: or %VSnn0COMNTOOLS%
call "%VS140COMNTOOLS%\vsvars32.bat"

:: XP ToolChain
:: https://gist.github.com/Ruzzz/79d07b11b8e61cfb105c4cc1dfefd9b1
call msvcxp.bat
set _BOOST_XP_DEFINES_=define=WINVER=0x0501 define=_WIN32_WINNT=0x0501 define=NTDDI_VERSION=0x05010000 define=PSAPI_VERSION=1

:: Additional
set BZIP2_SOURCE=c:\Dev\Libs\bzip2-1.0.6\
set ZLIB_SOURCE=c:\Dev\Libs\zlib-1.2.8\
:: define=BOOST_SIGNALS_NAMESPACE=boost_signal_ns

:: Build Boost
rd /q /s bin.v2
b2 %_BOOST_XP_DEFINES_% link=static threading=multi runtime-link=static address-model=32 debug release stage
move "stage/lib" "stage/lib_cl_x32_xp"
b2 %_BOOST_XP_DEFINES_% link=static threading=multi runtime-link=static address-model=64 debug release stage
move "stage/lib" "stage/lib_cl_x64_xp"