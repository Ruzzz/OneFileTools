# Updated: 2018/01/12 (yyyy/mm/dd)

# CMAKE_PREFIX_PATH
# set(X264_USE_ASM ON)

# x264/include/x264.h
#     /lib32/libx264.lib
#     /lib64/libx264.lib
#     /lib32_asm/libx264.lib
#     /lib64_asm/libx264.lib

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(LIB_SUFFIX lib64)
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(LIB_SUFFIX lib32)
endif()

if(X264_USE_ASM)
    set(LIB_SUFFIX ${LIB_SUFFIX}_asm)
endif()

find_path(X264_INCLUDE_DIR x264.h)
find_library(X264_LIBRARY libx264 PATH_SUFFIXES ${LIB_SUFFIX})

add_library(x264 STATIC IMPORTED)

set_target_properties(x264 PROPERTIES
    IMPORTED_LOCATION             ${X264_LIBRARY}
    INTERFACE_INCLUDE_DIRECTORIES ${X264_INCLUDE_DIR})
