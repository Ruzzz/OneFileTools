cd /d %1 || goto :EOF
del /f /s /q /A:H *.suo
del /f /s /q *.tlog *.lastbuildstate *.obj *.vc.db *.pch *.iobj *.ipdb *.ipch *.sdf *.log unsuccessfulbuild *.ilk *.tlog
for /f "delims=" %%d in ('dir /s /b /ad ^| sort /r') do rd "%%d"
:EOF