:: ruzzzua[]gmail.com

:: Используем так:
:: this.bat video.mp4
:: this.bat video.mp4 1920:960:0:60

@echo off
chcp 65001 > NUL

:LOOP
IF (%1)==() GOTO EOF
IF (%2)==() GOTO EOF

::set TEST=-hide_banner -ss 54 -t 15 -y
set TEST=-hide_banner
::set OUTFRM=-f image2 -vframes 1
::set OUTEXT=png
set OUTFRM=-f mp4
set OUTEXT=mp4
set AUDIO=-c:a aac -b:a 192k
::set AUDIO=-an
set VIDEO_PAN_SCALE=-vf "crop=%2,scale=-1:480:sws_flags=sinc,crop=640:480"
::set VIDEO_PAN_SCALE=-vf "scale=-1:480:sws_flags=sinc,crop=640:480"
::  -maxrate 2500k -bufsize 5000k
set VIDEO_1=-pix_fmt yuv420p -c:v libx264 -preset fast -profile:v high -tune film -crf 18 -r 25
::set VIDEO_A=-pix_fmt yuv420p -c:v libx264 -preset fast -profile:v high -tune film -b:v 1500k -pass 1
::set VIDEO_B=-pix_fmt yuv420p -c:v libx264 -preset fast -profile:v high -tune film -b:v 1500k -pass 2

::erase /Q *.%OUTEXT%
@echo on
ffmpeg %TEST% -i "%~1" %VIDEO_PAN_SCALE% %VIDEO_1% %AUDIO% %OUTFRM% "%~dpn1_tv.%OUTEXT%"
::ffmpeg %TEST% -i "%~1" %VIDEO_PAN_SCALE% %VIDEO_A% -an     %OUTFRM% NUL
::ffmpeg %TEST% -i "%~1" %VIDEO_PAN_SCALE% %VIDEO_B% %AUDIO% %OUTFRM% "%~dpn1.%OUTEXT%"
@echo off

SHIFT
SHIFT
GOTO :LOOP