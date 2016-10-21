::    _ __ _   _ ____________
::   | '__| | | |_  /_  /_  /
::   | |  | |_| |/ / / / / / 
::   |_|   \__,_/___/___/___|
::

@echo off

set MAIN=pstart
set SOURCE=..\src\%MAIN%.cpp
set OUT=..\bin\%MAIN%.exe

set CL=/W3 /O1 /GL /GF /MT /EHsc /DNDEBUG /DWIN32 /D_WINDOWS /D_UNICODE /DUNICODE
set LINK=/LTCG /OPT:REF /OPT:ICF /DYNAMICBASE /NXCOMPAT /SUBSYSTEM:WINDOWS,5.01 /SAFESEH

:: XP Toolset
set SDK71PATH=%ProgramFiles%\Microsoft SDKs\Windows\7.1A
path %SDK71PATH%\Bin;%PATH%
set CL=%CL% /D_USING_V110_SDK71_
set INCLUDE=%INCLUDE%;%SDK71PATH%\Include
set LIB=%SDK71PATH%\Lib;%LIB%

:: Prepare VC++2015 compiler
call "%VS140COMNTOOLS%\vsvars32.bat"
if errorlevel 1 goto :EOF

::Compile
chcp 65001 && cl.exe /nologo %SOURCE% /link /nologo /out:%OUT% && del *.obj
