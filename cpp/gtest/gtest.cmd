set __IN_DIR__=%DEV_LIBS_DISTR%\gtest
set __OUT_DIR__=%DEV_LIBS%\gtest

if not exist %__IN_DIR__% git clone --depth 1 https://github.com/google/googletest.git %__IN_DIR__%
if exist %__OUT_DIR__% rd /q /s %__OUT_DIR__%
mkdir %__OUT_DIR__%
pushd %__OUT_DIR__%
call python2 %__IN_DIR__%/googletest/scripts/fuse_gtest_files.py .
rename .\gtest\gtest-all.cc gtest.cc
copy "%~dp0\CMakeLists.txt" .
popd
