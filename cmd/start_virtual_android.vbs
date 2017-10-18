Set oShell = CreateObject("Wscript.Shell") 
Dim strArgs
strArgs = "%ANDROID_HOME%\\emulator\\emulator.exe -netdelay none -netspeed full -avd {TODO_DEVICE_NAME}"
oShell.Run strArgs, 0, false