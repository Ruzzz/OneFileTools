project(x264 C)

if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
endif()

file(GLOB_RECURSE SOURCES
    LIST_DIRECTORIES false RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.c")
list(REMOVE_ITEM SOURCES
    "src/encoder/rdo.c"
    "src/encoder/slicetype.c")

file(GLOB_RECURSE ASM_SOURCES
    LIST_DIRECTORIES false RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.asm")
source_group("Assembler Source Files" FILES ${ASM_SOURCES})
list(REMOVE_ITEM ASM_SOURCES
    "src/common/x86/x86inc.asm"
    "src/common/x86/x86util.asm")

file(GLOB_RECURSE HEADERS
    LIST_DIRECTORIES false RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/*.h")

add_library(x264 STATIC ${SOURCES} ${ASM_SOURCES} ${HEADERS})
target_include_directories(x264
    PUBLIC include
    PRIVATE src)

enable_language(ASM_NASM)
target_include_directories(x264 PRIVATE src/common/x86) # for ASM
set(CMAKE_ASM_NASM_FLAGS "${CMAKE_ASM_NASM_FLAGS} -p config.inc")

#
# cli
#

if (MAKE_X264CLI) # TODO: MAKE_X264CLI
    file(GLOB_RECURSE SOURCES_CLI
        LIST_DIRECTORIES false RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
        "${CMAKE_CURRENT_SOURCE_DIR}/cli/*.c")
    list(REMOVE_ITEM SOURCES_CLI
        "cli/input/avs.c"
        "cli/input/ffms.c"
        "cli/input/lavf.c"
        "cli/output/mp4.c"
        "cli/extras/nix/getopt.c")

    add_executable(x264cli ${SOURCES_CLI} ${SOURCES} ${ASM_SOURCES})

    target_include_directories(x264cli PRIVATE include cli src src/common/x86 cli/extras/win)
    target_link_libraries(x264cli x264)
    target_link_libraries(x264cli lsmash)
endif()