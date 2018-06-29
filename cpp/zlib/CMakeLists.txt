# zlib 1.2.11

project(zlib C)

if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
    add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)
    
    ENABLE_LANGUAGE(ASM_MASM)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(ARCH_SUFFIX 64)
        set(ZLIB_ASMS
            src/inffasx64.asm
            src/gvmat64.asm)
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
        set(ARCH_SUFFIX 32)
        set(ZLIB_ASMS
            src/inffas32.asm
            src/match686.asm)
    endif()
    if(ZLIB_ASMS)
        add_definitions(-DASMV -DASMINF)
        source_group("Asm" FILES ${ZLIB_ASMS})
    endif()
endif()

file(GLOB SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "src/*.c")
file(GLOB HEADERS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "include/*.h")

add_library(zlib STATIC ${SOURCES} ${ZLIB_ASMS} ${HEADERS})
target_include_directories(zlib PUBLIC include)
set_target_properties(zlib PROPERTIES
    DEBUG_POSTFIX                    ${CMAKE_DEBUG_POSTFIX}d
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/lib${ARCH_SUFFIX}
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG   ${CMAKE_BINARY_DIR}/lib${ARCH_SUFFIX})