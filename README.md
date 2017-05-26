## bin2cpp

Convert binary file to .cpp source file with 'unsigned char[]' inside.

```
Usage: bin2cpp bin-file [xor-byte] [bytes-per-line] [var-name]

  xor-byte                - Initial value for 'crypt'. Default 0.
  bytes-per-line          - Number of bytes in line. Default 8.
  var-name                - Name of var. Default FILE.
```

## zrun

- Add PATH to env var 'path' for CMD only.
- Show UAC if needed.
- Expand vars like %ProgramFiles% in CMD.
- Run CMD.
- Wait if needed.
- Return ERRORLEVEL (exit code) of CMD (-wait only).

```
Usage: zrun.exe [-path PATH] [-uac] [-wait] [-hide] CMD
```

Error codes:    
    
    - -1 - Unknown error
    - -2 - CMD used zrun's exit code
    - -3 - Cannot run CMD
    - -4 - Cannot elevate CMD
    
## explorertools

Windows Explorer tools.	Tested on WinXP-10

```
Usage: et.exe -r|-e|-s

Actions:
  -r                      - Safe restart.
  -e                      - Safe exit only.
  -s                      - If not running then start.
```

## uac

Show UAC if needed and run CMD. Very small utility.

```
Usage: uac.exe CMD
```
    
## gen_vc.cmd

Generate make.cmd file for build with VC++.

```
Usage: gen_vc.cmd [-vs2017] [-vs2015] [-vs2013] [-vs2012] [-vs2010]
                  [-vs2008] [-x64] [-ansi] [-con] [-xp] [-nocrt]
                  CL_PARAMS [-link LINK_PARAMS]
```

Example:

```
call gen_vc.cmd -nocrt -xp src\mcrt.c src\uac.c ^
    -link /out:bin\uac.exe>uac_make.cmd || goto :EOF
    
call gen_vc.cmd -nocrt -xp src\mcrt.c src\uac.c -x64 ^
    -link /out:bin\uac64.exe>uac_make64.cmd || goto :EOF
    
cmd /k uac_make.cmd || goto :EOF
cmd /k uac_make64.cmd || goto :EOF
```