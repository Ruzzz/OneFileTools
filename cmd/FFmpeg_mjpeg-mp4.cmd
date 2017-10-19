chcp 65001 > NUL
ffmpeg -hide_banner -i "%~1" -vf "smartblur" -pix_fmt yuv420p -c:v libx264 -preset fast -profile:v high -tune film -crf 25 -maxrate 2500k -bufsize 5000k -c:a aac -b:a 128k -f mp4 "%~dpn1.mp4"
