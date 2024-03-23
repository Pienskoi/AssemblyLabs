@echo off
ML /c /coff 7-17-IP-94-Pienskoi.asm
ML /c /coff 7-17-IP-94-Pienskoi-proc.asm
LINK /subsystem:windows 7-17-IP-94-Pienskoi.obj 7-17-IP-94-Pienskoi-proc.obj
