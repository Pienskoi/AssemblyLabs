.386
.model flat, stdcall
option casemap: none

include \masm32\include\user32.inc; wsprintf
include \masm32\include\fpu.inc; FpuFLtoA, constants SRC1_FPU, SRC2_DIMM
include \masm32\include\masm32.inc; FloatToStr2
 
includelib \masm32\lib\user32.lib; wsprintf
includelib \masm32\lib\fpu.lib; FpuFLtoA
includelib \masm32\lib\masm32.lib; FloatToStr2

.data
	dataMsg db "(2*%s + lg(%s) * 51)/(%s - %s - 1) = %s", 13, 13, 0
	divErrorMsg db "Division by zero error has occured:", 13,
					"d - a - 1 = %s - %s - 1 = 0!", 13, 13, 0
	logErrorMsg db "Logarithm error has occured:", 13,
				   "b = %s <= 0!", 13, 13, 0

.data?
	buffA db 64 dup (?)
	buffB db 64 dup (?)
	buffC db 64 dup (?)
	buffD db 64 dup (?)
	resBuffer db 64 dup (?)

.code
DllMain proc hInstDLL:dword, reason:dword, unused:dword
	mov eax, 1
	ret

DllMain endp

calculate proc valA:qword, valB:qword, valC:qword, valD:qword, result:ptr byte
	finit

	fld valC ; st(0) = c
	mov dword ptr [ebx], 2
	fimul dword ptr [ebx] ; st(0) = c*2

	fldlg2 ; st(0) = lg(2), st(1) = c*2
	fld valB ; st(0) = b, st(1) = lg(2), st(2) = c*2

	fldz ; st(0) = 0, st(1) = b, st(2) = lg(2), st(3) = c*2
	fcomp ; compare st(1) and st(0), st(0) = b, st(1) = lg(2), st(2) = c*2
	fstsw ax
	sahf
	jae logError

	fyl2x ; st(0) = lg(b), st(1) = c*2

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

	invoke FpuFLtoA, 0, 6, addr resBuffer, SRC1_FPU or SRC2_DIMM

	invoke FloatToStr2, valA, addr buffA
	invoke FloatToStr2, valB, addr buffB
	invoke FloatToStr2, valC, addr buffC
	invoke FloatToStr2, valD, addr buffD

	invoke wsprintf, result, addr dataMsg, 
	  addr buffA, addr buffB, addr buffC, addr buffD, addr resBuffer
	ret

	logError:
		invoke wsprintf, result, addr logErrorMsg, addr buffB
		ret
	divError:
		invoke wsprintf, result, addr divErrorMsg, addr buffD, addr buffA
		ret

calculate endp
	
end DllMain
