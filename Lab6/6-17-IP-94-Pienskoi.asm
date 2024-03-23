.386
.model flat, stdcall
option casemap: none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\fpu.inc
include \masm32\include\masm32.inc
 
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\fpu.lib
includelib \masm32\lib\masm32.lib

calculate macro valA, valB, valC, valD
	finit

	fld valC ; st(0) = c
	mov dword ptr [ebx], 2
	fimul dword ptr [ebx] ; st(0) = c*2

	fldlg2 ; st(0) = lg(2), st(1) = c*2
	fld valB ; st(0) = b, st(1) = lg(2), st(2) = c*2
	fyl2x ; st(0) = lg(b), st(1) = c*2

	fldz ; st(0) = 0, st(1) = lg(b), st(2) = c*2
	fcomp ; compare st(1) and st(0), st(0) = lg(b), st(1) = c*2
	fstsw ax
	sahf
	jle logError

	mov dword ptr [ebx], 51
	fimul dword ptr [ebx] ; st(0) = lg(b) * 51, st(1) = c*2

	fadd ; st(0) = lg(b) * 51 + c*2

	fld valD ; st(0) = d, st(1) = lg(b) * 51 + c*2
	fld valA ; st(0) = a, st(1) = d, st(2) = lg(b) * 51 + c*2
	fsub ; st(0) = d - a, st(1) = lg(b) * 51 + c*2

	fld1 ; st(0) = 1, st(1) = d - a, st(2) = lg(b) * 51 + c*2
	fsub ; st(0) = d - a - 1, st(1) = lg(b) * 51 + c*2

	fldz ; st(0) = 0, st(1) = d - a - 1, st(2) = lg(b) * 51 + c*2
	fcomp ; compare st(0) and st(1), st(0) = d - a - 1, st(1) = lg(b) * 51 + c*2
	fstsw ax
	sahf
	je divError

	fdiv ; st(0) = (lg(b) * 51 + c*2)/(d - a - 1)

	;fstp longDouble ; вивід проміжних результатів
	;jmp debug

	fstp result
	jmp data
	
endm

.data
	arrA dq 356.0, 10.5, -84.72, -9021.6, 9171.63, 53.2, 100.1
	arrB dq 100.0, 100.7, 10.8, 0.178, 329.23, -1.32, 747.3
	arrC dq -235.0, 10.04, -36.86, -5339.1, 0.77, 432.43, -483.2
	arrD dq 23.23, 12.58, 7.724, 35.115, 5.8, 213.384, 101.1

	arrLength equ lengthof arrA

	msgBoxTitle db "Lab 6", 0
	frmt db "%f", 13, 13, 0
	dataMsg db "(2*%s + lg(%s) * 51)/(%s - %s - 1) = %s", 13, 13, 0
	debugMsg db "%s", 13, 13, 0
	divErrorMsg db "Division by zero error has occured:", 13,
					"d - a - 1 = %s - %s - 1 = 0!", 13, 13, 0
	logErrorMsg db "Logarithm error has occured:", 13,
				   "b = %s <= 0!", 13, 13, 0

.data?
	result dq ?
	longDouble dt ?
	buffer db 1024 dup (?)
	resBuffer db 128 dup (?)
	inputBuffer db 32 dup (?)

.code
main:
	mov edi, 0
	mov esi, 0
	calc:
		invoke FloatToStr2, arrA[8*edi], addr inputBuffer[0]
		invoke FloatToStr2, arrB[8*edi], addr inputBuffer[8]
		invoke FloatToStr2, arrC[8*edi], addr inputBuffer[16]
		invoke FloatToStr2, arrD[8*edi], addr inputBuffer[24]

		calculate arrA[8*edi], arrB[8*edi], arrC[8*edi], arrD[8*edi]

		divError:
			invoke wsprintf, addr buffer[esi], addr divErrorMsg, addr inputBuffer[24], addr inputBuffer[0]
			jmp continue
		logError:
			invoke wsprintf, addr buffer[esi], addr logErrorMsg, addr inputBuffer[8]
			jmp continue
		data:
			invoke FloatToStr2, result, addr resBuffer
			invoke wsprintf, addr buffer[esi], addr dataMsg, 
			  addr inputBuffer[16], addr inputBuffer[8], addr inputBuffer[24], addr inputBuffer[0], addr resBuffer
			jmp continue
		debug:
			invoke FpuFLtoA, addr longDouble, 15, addr resBuffer, SRC1_REAL or SRC2_DIMM
			invoke wsprintf, addr buffer[esi], addr debugMsg, addr resBuffer
			jmp continue
		continue:
			add esi, eax 
			inc edi
			cmp edi, arrLength
			jl calc
	
	invoke MessageBox, 0, addr buffer, addr msgBoxTitle, MB_OK
    invoke ExitProcess, 0

end main
