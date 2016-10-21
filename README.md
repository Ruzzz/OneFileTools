## bin2cpp

Convert binary file to .cpp source file with 'unsigned char[]' inside.

    Usage: bin2cpp bin-file [xor-byte] [bytes-per-line] [var-name]
    
      xor-byte                - Initial value for 'crypt'. Default 0.
      bytes-per-line          - Number of bytes in line. Default 8.
      var-name                - Name of var. Default FILE.

## pstart

Add dirs to env var path, run target.exe, wait.

    Usage: pstart.exe [dir1] [dir2] [..] target.exe

## texplorer

Windows Explorer tools.	

    Usage: texplorer.exe -r|-e|-s

    Actions:
      -r                      - Safe restart.
      -e                      - Safe exit only.
      -s                      - If not running then start.
