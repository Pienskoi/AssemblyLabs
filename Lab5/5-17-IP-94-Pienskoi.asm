.386
.model flat, stdcall
option casemap: none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
 
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

calculate macro valA, valC, valD
	mov ax, valA; ax = a
	cwd; dx:ax = sign-extend of ax
	mov bx, 2; bx = 2
	idiv bx; ax = a/2
	mov bx, ax; bx = a/2

	mov ax, 4; ax = 4
	imul valD; dx:ax = 4*d
	push dx
	push ax
	pop eax; eax = 4*d

	movsx ebx, bx; ebx = sign-extend of bx
	sub ebx, eax; ebx = a/2 - 4*d
	sub ebx, 1; ebx = a/2 - 4*d - 1

	mov ax, valC; ax = c 
	imul valD; dx:ax = c*d
	push dx
	push ax
	pop eax; eax = c*d

	add eax, 23; eax = c*d + 23
	cdq; edx:eax = sign-extend of eax

	idiv ebx; eax = (c*d + 23)/(a/2 - 4*d - 1)
endm

checkParity macro val
	mov eax, val
	cdq; edx:eax = sign-extend of eax
	mov ebx, 2
	idiv ebx; eax = val/2, edx = val mod 2
	.if edx != 0
		mov eax, val
		mov ebx, 5
		imul ebx; edx:eax = val*5
		invoke wsprintf, addr parityBuffer, addr oddFormat, val, eax
	.else
		invoke wsprintf, addr parityBuffer, addr evenFormat, val, eax
	.endif
endm

.data
	arrA dw 2, -6, -52, 2020, 32766
	arrC dw 6, -3, 48, 11, 32767
	arrD dw 4, -3, 4, 105, 4095

	arrLength equ lengthof arrA

	msgBoxTitle db "Lab 5", 0
	format db "(%d*(%d) + 23)/(%d/2 - 4*(%d) - 1) = %d", 13,
			  "%s", 13, 13, 0
	oddFormat db "Odd: %d*5 = %d", 0
	evenFormat db "Even: %d/2 = %d", 0

.data?
	arrResult dd arrLength dup (?)
	buffer db 1024 dup (?)
	parityBuffer db 64 dup (?)
	finalBuffer db 10000 dup (?)

.code
main:
	mov edi, 0
	calc:
		calculate arrA[2*edi], arrC[2*edi], arrD[2*edi]
		mov arrResult[4*edi], eax
		inc edi
		cmp edi, arrLength
		jl calc
	mov edi, 0
	mov esi, 0
	print:
		checkParity arrResult[4*edi]
		mov bx, arrA[2*edi]
		movsx ebx, bx
		mov cx, arrC[2*edi]
		movsx ecx, cx
		mov dx, arrD[2*edi]
		movsx edx, dx
		invoke wsprintf, addr buffer[esi], addr format, ecx, edx, ebx, edx, arrResult[4*edi], addr parityBuffer
		inc edi
		add esi, eax
		cmp edi, arrLength
		jl print
	
	invoke MessageBox, 0, ADDR buffer, ADDR msgBoxTitle, MB_OK
    invoke ExitProcess, 0

end main
