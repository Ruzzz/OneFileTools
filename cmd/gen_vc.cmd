:: Author: Ruslan Zaporojets
:: Email:  ruzzzua[]gmail.com
:: Date:   2017-05-25
:: Usage:  gen_vc.cmd [-vs2017] [-vs2015] [-vs2013] [-vs2012] [-vs2010]
::                    [-vs2008] [-x64] [-ansi] [-con] [-xp] [-nocrt]
::                    CL_PARAMS [-link LINK_PARAMS]
@echo off
setlocal
set __IN__=kernel32.lib user32.lib shell32.lib advapi32.lib ole32.lib
set __NOCRT_DEFINE__=NOCRT
set __NOCRT_ENTRY__=main
set __DEF_VS_VER__=2017

echo @echo off
echo setlocal
echo :: Gen: %~nx0 %*

::
:: Parse Command Line Params
::

set __OUT__=
:PARAM_PARSE
if (%1)==() goto :PARAM_PARSED

if not (%1)==(-vs2017) goto :PARAM_CHECK_VS2015
set __VS_VER__=2017
goto :PARAM_NEXT

:PARAM_CHECK_VS2015
if not (%1)==(-vs2015) goto :PARAM_CHECK_VS2013
set __VS_VER__=2015
goto :PARAM_NEXT

:PARAM_CHECK_VS2013
if not (%1)==(-vs2013) goto :PARAM_CHECK_VS2012
set __VS_VER__=2013
goto :PARAM_NEXT

:PARAM_CHECK_VS2012
if not (%1)==(-vs2012) goto :PARAM_CHECK_VS2010
set __VS_VER__=2012
goto :PARAM_NEXT

:PARAM_CHECK_VS2010
if not (%1)==(-vs2010) goto :PARAM_CHECK_VS2008
set __VS_VER__=2010
goto :PARAM_NEXT

:PARAM_CHECK_VS2008
if not (%1)==(-vs2008) goto :PARAM_CHECK_X64
set __VS_VER__=2008
goto :PARAM_NEXT

:PARAM_CHECK_X64
if not (%1)==(-x64) goto :PARAM_CHECK_ANSI
set __ARCH__=x64
goto :PARAM_NEXT

:PARAM_CHECK_ANSI
if not (%1)==(-ansi) goto :PARAM_CHECK_CON
set __ANSI__=1
goto :PARAM_NEXT

:PARAM_CHECK_CON
if not (%1)==(-con) goto :PARAM_CHECK_XP
set __MACHINE__=CONSOLE
goto :PARAM_NEXT

:PARAM_CHECK_XP
if not (%1)==(-xp) goto :PARAM_CHECK_NOCRT
set __XP_TOOLCHAIN__=1
goto :PARAM_NEXT

:PARAM_CHECK_NOCRT
if not (%1)==(-nocrt) goto :PARAM_CHECK_LINK
set __NOCRT__=1
goto :PARAM_NEXT

:PARAM_CHECK_LINK
if not (%1)==(-link) goto :PARAM_NO
:PARAM_CHECK_LINK_LOOP
shift
if (%1)==() goto :PARAM_PARSED
set __OUT__=%__OUT__% %1
goto :PARAM_CHECK_LINK_LOOP

:PARAM_NO
set __IN__=%__IN__% %1
:PARAM_NEXT
shift
goto :PARAM_PARSE
:PARAM_PARSED

::
:: Init Toolchain
::

set __CL__=/W4 /MT /GF /D NDEBUG /D WIN32 /D _WINDOWS
if (%__ANSI__%)==() set __CL__=%__CL__% /D _UNICODE /D UNICODE
set __LINK__=/OPT:REF /OPT:ICF
if (%__MACHINE__%)==() set __MACHINE__=WINDOWS
if (%__XP_TOOLCHAIN__%)==() set __LINK__=%__LINK__% /SUBSYSTEM:%__MACHINE__%

if not (%__ARCH__%)==(x64) goto :ARCH_X32
set __LINK__=%__LINK__% /MACHINE:X64
goto :ARCH_END
:ARCH_X32
set __ARCH__=x86
set __LINK__=%__LINK__% /MACHINE:X86
:ARCH_END

if not (%__NOCRT__%)==() goto :NOCRT
set __CL__=%__CL__% /O2 /GL /GS /EHsc 
set __LINK__=%__LINK__% /LTCG /DYNAMICBASE /NXCOMPAT
if (%__ARCH__%)==(x64) goto :NOCRT_END
set __LINK__=%__LINK__% /SAFESEH
goto :NOCRT_END

:NOCRT
set __CL__=%__CL__% /O1 /GS- /EHsa- /D %__NOCRT_DEFINE__%
set __LINK__=%__LINK__% /DYNAMICBASE:NO /NXCOMPAT:NO /FIXED /NODEFAULTLIB /MERGE:.rdata=.text /ENTRY:%__NOCRT_ENTRY__%
if (%__ARCH__%)==(x64) goto :NOCRT_END
set __CL__=%__CL__% /GL
set __LINK__=%__LINK__% /LTCG
:NOCRT_END

::
:: Init XP ToolChain
::

if (%__XP_TOOLCHAIN__%)==() goto :XP_END
set __CL__=%__CL__% /D_USING_V110_SDK71_
if not (%__ARCH__%)==(x64) goto :XP_X32
set __LINK__=%__LINK__% /SUBSYSTEM:%__MACHINE__%,5.02
set __XP_PATH_SUFFIX__=\x64
goto :XP_X32_END
:XP_X32
set __LINK__=%__LINK__% /SUBSYSTEM:%__MACHINE__%,5.01
set __XP_PATH_SUFFIX__=
:XP_X32_END
echo :: Init XP ToolChain
echo set SDK71PATH=%%ProgramFiles%%\Microsoft SDKs\Windows\7.1A
echo path %%SDK71PATH%%\Bin%__XP_PATH_SUFFIX__%;%%PATH%%
echo set INCLUDE=%%INCLUDE%%;%%SDK71PATH%%\Include
echo set LIB=%%LIB%%;%%SDK71PATH%%\Lib%__XP_PATH_SUFFIX__%
echo.
:XP_END

::
:: Init VC++ compiler
::

echo :: Build
if (%__VS_VER__%)==() set __VS_VER__=%__DEF_VS_VER__%
if (%__VS_VER__%)==(2017) goto :BUILD_VS2017

if not (%__ARCH__%)==(x64) goto :BUILD_VCVARS_X32
set __VCVARS__=..\..\VC\bin\amd64\vcvars64.bat
goto :BUILD_VCVARS_AFTER
:BUILD_VCVARS_X32
set __VCVARS__=..\..\VC\bin\vcvars32.bat
:BUILD_VCVARS_AFTER

if (%__VS_VER__%)==(2015) goto :BUILD_VS2015
if (%__VS_VER__%)==(2013) goto :BUILD_VS2013
if (%__VS_VER__%)==(2012) goto :BUILD_VS2012
if (%__VS_VER__%)==(2010) goto :BUILD_VS2010
if (%__VS_VER__%)==(2008) goto :BUILD_VS2008

set __ERROR__=Invalid compiler version: %__VS_VER__%
goto :ERROR

:BUILD_VS2008
echo call "%%VS90COMNTOOLS%%\%__VCVARS__%"
goto :BUILD

:BUILD_VS2010
echo call "%%VS100COMNTOOLS%%\%__VCVARS__%"
goto :BUILD

:BUILD_VS2012
echo call "%%VS110COMNTOOLS%%\%__VCVARS__%"
goto :BUILD

:BUILD_VS2013
echo call "%%VS120COMNTOOLS%%\%__VCVARS__%"
goto :BUILD

:BUILD_VS2015
echo :: VS140COMNTOOLS_in_VS2017_fix.reg
echo :: https://gist.github.com/Ruzzz/38dc70f4b850dd5e379f8cfa2cbf09a3
echo call "%%VS140COMNTOOLS%%\%__VCVARS__%"
goto :BUILD

:BUILD_VS2017
echo :: VS150COMNTOOLS_fix.cmd
echo :: https://gist.github.com/Ruzzz/754abea012dc9e5825e33ff3ccb67296
echo call "%%VS150COMNTOOLS%%\..\..\VC\Auxiliary\Build\vcvarsall.bat" %__ARCH__%
:: echo call "%%VS150COMNTOOLS%%\VsDevCmd.bat" -arch=%__ARCH__%
goto :BUILD

::
:: Build
::

:BUILD
echo if ERRORLEVEL 1 goto :ERROR
echo set CL=%__CL__%
echo set LINK=%__LINK__%
echo cl.exe /nologo %__IN__% /link /nologo%__OUT__%
echo if ERRORLEVEL 1 goto :ERROR
echo del *.obj^>nul
echo endlocal
echo exit 0
echo.
echo :ERROR
echo endlocal
echo set ERRORLEVEL=%%ERRORLEVEL%%
echo pause
echo del *.obj^>nul
echo exit %%ERRORLEVEL%%

endlocal
exit /b 0
:ERROR
echo [genvc.cmd] ERROR: %__ERROR__% >&2
endlocal
pause
exit /b 1
