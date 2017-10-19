:: ruzzzua[]gmail.com

:: Используем так:

:: this.bat video.mp4
::   - смотрим, закрываем видео окно, копируем из консоли
::     строку ввида 1920:960:0:60

:: this.bat video.mp4 1920:960:0:60
::   - смотрим хорош ли результат, если да то 1920:960:0:60 используем
::     для encode.bat 1920:960:0:60

@echo off
chcp 65001 > NUL
IF (%1)==() GOTO EOF
IF (%2)==() GOTO :DETECT

:: Preview
ffplay -i "%~1" -vf "crop=%2,scale=-1:480:sws_flags=sinc,crop=640:480"
GOTO EOF

:: Detect
:DETECT
::ffmpeg -ss 90 -i "%~1" -vframes 10 -vf cropdetect -f null -
ffplay -i "%~1" -vf "cropdetect=24:16:0"
pause