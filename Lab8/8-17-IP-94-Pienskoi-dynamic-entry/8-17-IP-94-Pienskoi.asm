.386
.model flat, stdcall
option casemap: none

include \masm32\include\windows.inc; constant MB_OK
include \masm32\include\user32.inc; MessageBox
include \masm32\include\kernel32.inc; LoadLibrary, GetProcAddress, FreeLibrary, ExitProcess
 
includelib \masm32\lib\user32.lib; MessageBox
includelib \masm32\lib\kernel32.lib; LoadLibrary, GetProcAddress, FreeLibrary, ExitProcess

funcProto typedef proto near :qword, :qword, :qword, :qword, :ptr byte
funcptr typedef ptr funcProto

.data
	libName db "8-17-IP-94-Pienskoi-dll.dll", 0
	funcName db "calculate", 0

	arrA dq 356.0, 10.5, -84.72, -9021.6, 9171.63, 53.2, 100.1
	arrB dq 100.0, 100.7, 10.8, 0.178, 329.23, -1.32, 747.3
	arrC dq -235.0, 10.04, -36.86, -5339.1, 0.77, 432.43, -483.2
	arrD dq 23.23, 12.58, 7.724, 35.115, 5.8, 213.384, 101.1

	arrLength equ lengthof arrA

	msgBoxTitle db "Lab 8", 0

.data?
	buffer db 1024 dup (?)
	hLib dd ?
	pCalc dd ?

.code
main:
	invoke LoadLibrary, addr libName
	mov hLib, eax
	invoke GetProcAddress, hLib, addr funcName
	mov pCalc, eax

	mov edi, 0
	mov esi, 0
	calc:
		invoke funcptr ptr pCalc, arrA[8*edi], arrB[8*edi], arrC[8*edi], arrD[8*edi], addr buffer[esi]

		add esi, eax 
		inc edi
		cmp edi, arrLength
		jl calc
	
	invoke FreeLibrary, hLib

	invoke MessageBox, 0, addr buffer, addr msgBoxTitle, MB_OK
    invoke ExitProcess, 0

end main
