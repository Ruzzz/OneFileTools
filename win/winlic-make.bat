::    _ __ _   _ ____________
::   | '__| | | |_  /_  /_  /
::   | |  | |_| |/ / / / / / 
::   |_|   \__,_/___/___/___|
::

@echo off

set MAIN=winlic
set SOURCE=..\src\%MAIN%.cpp kernel32.lib advapi32.lib
set OUT=..\bin\%MAIN%.exe

set CL=/W3 /O1 /GL /GF /GS- /MT /EHa- /DNDEBUG /DWIN32 /D_WINDOWS /D_UNICODE /DUNICODE
set LINK=/LTCG /OPT:REF /OPT:ICF /DYNAMICBASE:NO /NXCOMPAT:NO /SUBSYSTEM:CONSOLE,5.01 /FIXED /NODEFAULTLIB /MERGE:.rdata=.text /ENTRY:main

:: XP Toolset
set SDK71PATH=%ProgramFiles%\Microsoft SDKs\Windows\7.1A
path %SDK71PATH%\Bin;%PATH%
set CL=%CL% /D_USING_V110_SDK71_
set INCLUDE=%INCLUDE%;%SDK71PATH%\Include
set LIB=%SDK71PATH%\Lib;%LIB%

:: Prepare VC2015 compiler
call "%VS140COMNTOOLS%\vsvars32.bat"
if errorlevel 1 goto :EOF

::Compile
chcp 65001 && cl.exe /nologo %SOURCE% /link /nologo /out:%OUT% && del *.obj