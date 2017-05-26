call ..\cmd\gen_vc.cmd -nocrt -ansi -xp -con ..\src\mcrt.c ..\src\explorertools.c -link /out:..\bin\et.exe>explorertools_make.cmd || goto :EOF
call ..\cmd\gen_vc.cmd -nocrt -ansi -xp -con ..\src\mcrt.c ..\src\explorertools.c -x64 -link /out:..\bin\et64.exe>explorertools_make64.cmd || goto :EOF
cmd /k explorertools_make.cmd || goto :EOF
cmd /k explorertools_make64.cmd || goto :EOF