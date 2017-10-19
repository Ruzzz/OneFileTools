:: https://gist.github.com/Ruzzz/97556cda4014a79bba90
:: FOLDER_DEST FOLDER_SRC NAME [NAME...]

set root_dest=%~1
set root_src=%~2

:loop
set filename=%~3
if ("%filename%")==("") goto :eof

rd /s /q "%root_dest%\%filename%"
mklink /d "%root_dest%\%filename%" "%root_src%\%filename%"

shift
goto :loop
