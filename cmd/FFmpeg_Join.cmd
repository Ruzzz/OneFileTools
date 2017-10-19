:: ruzzzua[]gmail.com

:: Склеивает отдельные файлы видео и аудио,
::   например если мы скачали проснифали трафик YouTube.

:: Используем:
::   this.bat youtube_video.mp4 youtube_audio.mp4 dest.mp4

cp 65001
ffmpeg -i "%~1" -i "%~2" -map 0:0 -map 1:0 -c:v copy -c:a copy "%~3"