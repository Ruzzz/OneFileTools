attrib -r -h -s "%~1"
fsutil sparse setflag "%~1" 0
PowerShell -Command Mount-DiskImage -ImagePath "%~1"