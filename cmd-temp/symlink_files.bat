:: https://gist.github.com/Ruzzz/41d6bffed6db309ca36f
:: FOLDER_DEST FOLDER_SRC NAME [NAME...]

set root_dest=%~1
set root_src=%~2

:loop
set filename=%~3
if ("%filename%")==("") goto :eof

del /f /q "%root_dest%\%filename%"
mklink "%root_dest%\%filename%" "%root_src%\%filename%"

shift
goto :loop
