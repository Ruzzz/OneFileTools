:: zlib 1.2.11

md include
copy zconf.h .\include
copy zlib.h .\include

md src
copy *.h .\src
copy *.c .\src
copy .\contrib\masmx86\*.asm .\src
copy .\contrib\masmx64\*.asm .\src