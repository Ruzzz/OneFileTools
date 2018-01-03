#!/bin/bash
# USAGE: this.sh IN_DIR OUT_DIR 


# Default params
NO_ASM_OPT=--disable-asm
IN_DIR=
OUT_DIR=


# Parse params
while [ "$1" != "" ]; do
    case $1 in
        -i | --in )     shift 
                        IN_DIR=$1
                        ;;
        -o | --out )    shift 
                        OUT_DIR=$1
                        ;;
        -a | --asm )    NO_ASM_OPT=
                        ;;
        * )             exit 1
    esac
    shift
done


# Make
# cd "$( dirname "${BASH_SOURCE[0]}" )"/$IN_REL_DIR
cd $IN_DIR
CC=cl ./configure \
    --prefix=$OUT_DIR \
    --disable-cli \
    --enable-static \
    --bit-depth=8 \
    --enable-pic \
    --disable-opencl \
    $NO_ASM_OPT \
    --extra-cflags="-MT"
make
make install
