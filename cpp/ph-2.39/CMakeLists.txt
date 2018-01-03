project(ph C)

add_definitions(-DUNICODE)
add_definitions(-D_UNICODE)
add_definitions(-D_CRT_SECURE_NO_WARNINGS)
add_definitions(-D_PHLIB_)

file(GLOB_RECURSE PHLIB_SOURCES
    LIST_DIRECTORIES false RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/phlib/src/*.c")
source_group("Source Files\\phlib" FILES ${PHLIB_SOURCES})

file(GLOB_RECURSE PHLIB_HEADERS
    LIST_DIRECTORIES false RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/phlib/include/*.h")
source_group("Header Files\\phlib" FILES ${PHLIB_HEADERS})

file(GLOB_RECURSE PHNT_HEADERS
    LIST_DIRECTORIES false RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/phnt/include/*.h")
source_group("Header Files\\phnt" FILES ${PHNT_HEADERS})
   
add_library(ph STATIC ${PHLIB_SOURCES} ${PHLIB_HEADERS} ${PHNT_HEADERS})
target_include_directories(ph PUBLIC phlib/include phnt/include)