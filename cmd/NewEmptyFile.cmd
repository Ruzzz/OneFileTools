@echo off
set /p FILENAME=Input filename (or ENTER for cancel):
if "%FILENAME%"=="" goto :EOF
copy nul "%~dp1%FILENAME%"