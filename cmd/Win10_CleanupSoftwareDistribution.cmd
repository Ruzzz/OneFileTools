Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase
pause

net stop wuauserv
net stop BITS
net stop CryptSvc
pause

cd %SystemRoot%
ren SoftwareDistribution SoftwareDistribution.old
pause

net start wuauserv
net start bits
net start CryptSvc
rd /s /q SoftwareDistribution.old
pause