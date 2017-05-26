call ..\cmd\gen_vc.cmd -con -xp ..\src\bin2cpp.cpp -link /out:..\bin\bin2cpp.exe>bin2cpp_make.cmd || goto :EOF
call ..\cmd\gen_vc.cmd -con -xp ..\src\bin2cpp.cpp -x64 -link /out:..\bin\bin2cpp64.exe>bin2cpp_make64.cmd || goto :EOF
cmd /k bin2cpp_make.cmd || goto :EOF
cmd /k bin2cpp_make64.cmd || goto :EOF