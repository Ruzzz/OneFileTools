project(lsmash)

file(GLOB_RECURSE SOURCES
    LIST_DIRECTORIES false RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.c")

file(GLOB_RECURSE HEADERS
    LIST_DIRECTORIES false RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/*.h")

add_library(lsmash STATIC ${SOURCES} ${HEADERS})
target_include_directories(lsmash
    PUBLIC ./include
    PRIVATE ./src)