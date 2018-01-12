# CMAKE_PREFIX_PATH
# set(FFMPEG_USE_ASM ON)
# target_link_libraries(${PROJECT_NAME} ffmpeg::avcodec ffmpeg::avutil ffmpeg::swresample ffmpeg::swscale)

# ffmpeg/include32/libavcodec/avcodec.h
#       /include64/libavcodec/avcodec.h
#       /lib32/libavcodec.lib
#       /lib64/libavcodec.lib

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(LIB_SUFFIX lib64)
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(LIB_SUFFIX lib32)
endif()
if(FFMPEG_USE_ASM)
    set(INC_SUFFIX include_asm)
    set(LIB_SUFFIX ${LIB_SUFFIX}_asm)
endif()

find_path(FFMPEG_INCLUDE_DIR libavcodec/avcodec.h PATH_SUFFIXES ${INC_SUFFIX})
    
macro(_ffmpeg_find_library lib_name)
    find_library(FFMPEG_${lib_name}_LIBRARY lib${lib_name} PATH_SUFFIXES ${LIB_SUFFIX})
    add_library(ffmpeg::${lib_name} STATIC IMPORTED)
    set_target_properties(ffmpeg::${lib_name} PROPERTIES
        IMPORTED_LOCATION             ${FFMPEG_${lib_name}_LIBRARY}
        INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR})
endmacro()    

set(_FFMPEG_LIB_NAMES avcodec avdevice avfilter avformat avutil postproc swresample swscale)
foreach(lib_name ${_FFMPEG_LIB_NAMES})
    _ffmpeg_find_library(${lib_name})
endforeach()