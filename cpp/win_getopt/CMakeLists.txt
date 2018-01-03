project(getopt)

add_library(getopt STATIC getopt.c getopt.h)
target_include_directories(getopt PUBLIC .)