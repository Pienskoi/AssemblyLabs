.386
.model flat, stdcall
option casemap: none

extern arrA: qword, arrD: qword, denominator: qword
public Proc_Denominator

.code
Proc_Denominator proc
	finit
	fld arrD[8*edi] ; st(0) = d
	fld arrA[8*edi] ; st(0) = a, st(1) = d
	fsub ; st(0) = d - a
	fld1 ; st(0) = 1, st(1) = d - a
	fsub ; st(0) = d - a - 1
	fstp denominator

	ret

Proc_Denominator endp

end
