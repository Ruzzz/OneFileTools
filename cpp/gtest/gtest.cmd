set __IN_DIR__=d:\Libs\dist\gtest
set __OUT_DIR__=d:\Libs\bin\gtest


if not exist %__IN_DIR__% git clone --depth 1 https://github.com/google/googletest.git %__IN_DIR__%
if not exist %__OUT_DIR__% mkdir %__OUT_DIR__%
pushd %__OUT_DIR__%
del /q gtest\*.h gtest\*.c*
call python2 %__IN_DIR__%/googletest/scripts/fuse_gtest_files.py .
copy "%~dp0\CMakeLists.txt" .
popd