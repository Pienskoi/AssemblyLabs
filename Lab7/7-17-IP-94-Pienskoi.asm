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

.data
	arrA dq 356.0, 10.5, -84.72, -9021.6, 9171.63, 53.2, 100.1
	arrB dq 100.0, 100.7, 10.8, 0.178, 329.23, -1.32, 747.3
	arrC dq -235.0, 10.04, -36.86, -5339.1, 0.77, 432.43, -483.2
	arrD dq 23.23, 12.58, 7.724, 35.115, 5.8, 213.384, 101.1

	arrLength equ lengthof arrA

	msgBoxTitle db "Lab 7", 0
	frmt db "%f", 13, 13, 0
	dataMsg db "(2*%s + lg(%s) * 51)/(%s - %s - 1) = %s", 13, 13, 0
	divErrorMsg db "Division by zero error has occured:", 13,
					"d - a - 1 = %s - %s - 1 = 0!", 13, 13, 0
	logErrorMsg db "Logarithm error has occured:", 13,
				   "b = %s <= 0!", 13, 13, 0

.data?
	numeratorFirstSummand dq ?
	numeratorSecondSummand dq ?
	denominator dq ?
	buffer db 1024 dup (?)
	resBuffer db 128 dup (?)
	inputBuffer db 32 dup (?)

extern Proc_Denominator@0: near
public arrA, arrD, denominator

.code
Proc_NumeratorFirstSummand proc
	finit
	fld qword ptr [ecx] ; st(0) = c
	mov dword ptr [ebx], 2
	fimul dword ptr [ebx] ; st(0) = c*2
	fstp qword ptr [edx]

	ret

Proc_NumeratorFirstSummand endp

Proc_NumeratorSecondSummand proc
	push ebp
	mov ebp, esp

	finit
	fldlg2 ; st(0) = lg(2)
	mov ebx, [ebp+8]
	fld qword ptr [ebx] ; st(0) = b, st(1) = lg(2)
	fyl2x ; st(0) = lg(b)
	mov dword ptr [ebx], 51
	fimul dword ptr [ebx] ; st(0) = lg(b) * 51
	fstp numeratorSecondSummand

	pop ebp
	ret 8

Proc_NumeratorSecondSummand endp

main:
	mov edi, 0
	mov esi, 0
	calc:

		invoke FloatToStr2, arrA[8*edi], addr inputBuffer[0]
		invoke FloatToStr2, arrB[8*edi], addr inputBuffer[8]
		invoke FloatToStr2, arrC[8*edi], addr inputBuffer[16]
		invoke FloatToStr2, arrD[8*edi], addr inputBuffer[24]

		lea ecx, arrC[8*edi]
		mov edx, offset numeratorFirstSummand
		call Proc_NumeratorFirstSummand
		
		finit
		fld arrB[8*edi]
		fldz
		fcomp
		fstsw ax
		sahf
		jae logError

		lea ebx, arrB[8*edi]
		push ebx
		call Proc_NumeratorSecondSummand

		call Proc_Denominator@0

		finit
		fld numeratorFirstSummand
		fld numeratorSecondSummand
		fadd

		fld denominator
		fldz
		fcomp
		fstsw ax
		sahf
		je divError

		fdiv

		invoke FpuFLtoA, 0, 6, addr resBuffer, SRC1_FPU or SRC2_DIMM
		invoke wsprintf, addr buffer[esi], addr dataMsg, 
		  addr inputBuffer[16], addr inputBuffer[8], addr inputBuffer[24], addr inputBuffer[0], addr resBuffer
		jmp continue

		divError:
			invoke wsprintf, addr buffer[esi], addr divErrorMsg, addr inputBuffer[24], addr inputBuffer[0]
			jmp continue
		logError:
			invoke wsprintf, addr buffer[esi], addr logErrorMsg, addr inputBuffer[8]
			jmp continue
		continue:
			add esi, eax 
			inc edi
			cmp edi, arrLength
			jl calc
	
	invoke MessageBox, 0, addr buffer, addr msgBoxTitle, MB_OK
    invoke ExitProcess, 0

end main
