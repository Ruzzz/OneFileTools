call ..\cmd\gen_vc.cmd -nocrt -xp ..\src\mcrt.c ..\src\uac.c -link /out:..\bin\uac.exe>uac_make.cmd || goto :EOF
call ..\cmd\gen_vc.cmd -nocrt -xp ..\src\mcrt.c ..\src\uac.c -x64 -link /out:..\bin\uac64.exe>uac_make64.cmd || goto :EOF
cmd /k uac_make.cmd || goto :EOF
cmd /k uac_make64.cmd || goto :EOF