@echo off
ML /c /coff 8-17-IP-94-Pienskoi-dll.asm
LINK /subsystem:windows /dll /export:calculate 8-17-IP-94-Pienskoi-dll.obj
ML /coff 8-17-IP-94-Pienskoi.asm /link /subsystem:windows
