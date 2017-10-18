REM run as admin, picture must be JPEG, picture size must be not more than 256KB
REM SET img_path=%1 or SET img_path="path to jpg" or
SET img_path=%~dp0background.jpg
SET bg_path=%SystemRoot%\system32\oobe\info\backgrounds
MD %bg_path%
COPY %img_path% %bg_path%\BackgroundDefault.jpg
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background" /v OEMBackground /t REG_DWORD /d 1 /f
REM Shadow of controls: 0 - transparent shadow, 1 - shadow, 2 - no shadow
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v ButtonSet /t REG_DWORD /d 1 /f
