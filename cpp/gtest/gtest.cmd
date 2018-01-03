set IN_DIR=d:/Libs/dist/gtest
set OUT_DIR=d:/Libs/bin/gtest

if not exist %IN_DIR% git clone --depth 1 https://github.com/google/googletest.git %IN_DIR%
if exist %OUT_DIR% rd /q /s %OUT_DIR%
mkdir %OUT_DIR%
call python2 %IN_DIR%/googletest/scripts/fuse_gtest_files.py %OUT_DIR%
