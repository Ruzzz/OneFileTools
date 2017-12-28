::git clone --depth 1 https://github.com/google/googletest.git
if exist gtest rd /q /s gtest
mkdir gtest
call python2 ./googletest/googletest/scripts/fuse_gtest_files.py .
rd /q /s googletest