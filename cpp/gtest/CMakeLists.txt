project(gtest)
set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE)
add_library(gtest STATIC gtest/gtest.cc gtest/gtest.h)
target_include_directories(gtest PUBLIC .)
