call ..\cmd\gen_vc.cmd -con -xp ..\src\[APPLICATION].cpp -link /out:..\bin\[APPLICATION].exe>[APPLICATION]_make.cmd || goto :EOF
call ..\cmd\gen_vc.cmd -con -xp ..\src\[APPLICATION].cpp -x64 -link /out:..\bin\[APPLICATION]64.exe>[APPLICATION]_make64.cmd || goto :EOF
cmd /k [APPLICATION]_make.cmd || goto :EOF
cmd /k [APPLICATION]_make64.cmd || goto :EOF