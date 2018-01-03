# About

- Based on build 152 (see X264_BUILD in x264.h)
- Asm version (without --disable-asm), note: use nasm or yarm
- Used --enable-pic
- Now win x64 version only

# How to make

- Make in [include] files:
    - x264_config.h
- Make in [src] files:
    - config.h
	- config.inc - copy of 'config.h' for asm
- Move to [include] files:
    - x264.h
- Move to [src] dirs:
    - [encoder], exclude files: 
        - slicetype-cl.c (OpenCL)
    - [common], exclude files:
	    - opencl.* (OpenCL)
	- [common/x86], exclude files:
	    - *32*.asm
		- *16*.asm
- TODO: CLI
    
# ToDo

- Support x32
- Support --disable-asm