#!/bin/bash
# USAGE: this.sh [--asm] [--x32] --in IN_DIR --out OUT_DIR --h264-include H264_INCLUDE --h264-lib H264_LIB


# Default params
NO_ASM_OPT=--disable-asm
PLATFORM=x86_64  # or amd64
TARGET_OS=win64
IN_DIR=
OUT_DIR=
H264_INCLUDE=
H264_LIB=


# Parse params
while [ "$1" != "" ]; do
    case $1 in
        -i | --in )     shift
                        IN_DIR=${1//\\//}
                        ;;
        -o | --out )    shift
                        OUT_DIR=${1//\\//}
                        ;;
        -a | --asm )    NO_ASM_OPT=
                        ;;
        --h264-include ) shift
                        H264_INCLUDE=${1//\\//}
                        ;;
        --h264-lib )    shift
                        H264_LIB=${1//\\//}
                        ;;
        --x32 )         PLATFORM=x86_32  # or x86
                        TARGET_OS=win32
                        ;;
        * )             exit 1
    esac
    shift
done


# Make
cd $IN_DIR

# if false; then
# TODO: --disable-everything --disable-swresample --disable-avdevice --disable-avformat --disable-postproc --disable-avfilter
CC=cl ./configure \
    --disable-everything \
    --prefix=$OUT_DIR \
    --toolchain=msvc \
    --enable-gpl \
    $NO_ASM_OPT \
    --disable-programs \
    --disable-doc \
    --arch=$PLATFORM \
    --enable-pic \
    --target-os=$TARGET_OS \
    --enable-libx264 \
    --enable-decoder=h264 \
    --enable-encoder=libx264 \
    --extra-cflags="-MT -I$H264_INCLUDE -DNO_PREFIX -fPIC" \
    --extra-cflags="-MT -I$H264_INCLUDE -DNO_PREFIX -fPIC" \
    --extra-ldflags="-LIBPATH:$H264_LIB"
# fi

make clean
make
make install
