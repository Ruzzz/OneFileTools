set __OUT_DIR__=%DEV_LIBS%\cld2

if exist %__OUT_DIR__% rd /q /s %__OUT_DIR__%
git clone --depth 1 https://github.com/CLD2Owners/cld2.git %__OUT_DIR__%
copy "%~dp0\CMakeLists.txt" %__OUT_DIR__%
