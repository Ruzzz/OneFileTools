call ..\cmd\gen_vc.cmd -con -xp ..\src\zrun.cpp -link /out:..\bin\zrun.exe>zrun_make.cmd || goto :EOF
call ..\cmd\gen_vc.cmd -con -xp ..\src\zrun.cpp -x64 -link /out:..\bin\zrun64.exe>zrun_make64.cmd || goto :EOF
if not exist "..\bin" mkdir "..\bin"
cmd /k zrun_make.cmd || goto :EOF
cmd /k zrun_make64.cmd || goto :EOF