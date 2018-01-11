# Set CMAKE_PREFIX_PATH

# ffmpeg/include32/libavcodec/avcodec.h
#       /include64/libavcodec/avcodec.h
#       /lib32/libavcodec.lib
#       /lib64/libavcodec.lib

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(LIB_SUFFIX lib64)
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(LIB_SUFFIX lib32)
endif()
set(INC_SUFFIX include_asm)
set(LIB_SUFFIX ${LIB_SUFFIX}_asm)

find_path(FFMPEG_INCLUDE_DIR libavcodec/avcodec.h PATH_SUFFIXES ${INC_SUFFIX})
find_library(FFMPEG_LIBRARY
    libavcodec libavdevice libavfilter libavformat libavutil libpostproc libswresample libswscale
    PATH_SUFFIXES ${LIB_SUFFIX})

add_library(ffmpeg STATIC IMPORTED)
set_target_properties(ffmpeg PROPERTIES
    IMPORTED_LOCATION             ${FFMPEG_LIBRARY}
    INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR})