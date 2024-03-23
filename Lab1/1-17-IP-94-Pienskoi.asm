.386
option casemap: none

include \masm32\include\masm32rt.inc

.data
      strTitle db "Lab1", 0
      
      string db "28062001", 0
      
      bytePlusA db 28
      byteMinusA db -28
      wordPlusA dw 28
      wordMinusA dw -28
      dwordPlusA dd 28
      dwordMinusA dd -28
      qwordPlusA dq 28
      qwordMinusA dq -28
      
      wordPlusB dw 2806
      wordMinusB dw -2806
      dwordPlusB dd 2806
      dwordMinusB dd -2806
      qwordPlusB dq 2806
      qworsMinusB dq -2806
      
      dwordPlusC dd 28062001
      dwordMinusC dd -28062001
      qwordPlusC dq 28062001
      qwordMinusC dq -28062001
      
      floatPlusD dd 0.003
      floatMinusD dd -0.003
      doublePlusD dq 0.003
      doubleMinusD dq -0.003
      
      doublePlusE dq 0.298
      doubleMinusE dq -0.298
      
      longDoublePlusF dt 2978.349
      longDoubleMinusF dt -2978.349
      doublePlusF dq 2978.349
      doubleMinusF dq -2978.349
      
      format db "ddmmyyyy: %s", 13,
                "A = %d", 13,
                "-A = %d", 13,
                "B = %d", 13,
                "-B = %d", 13,
                "C = %d", 13,
                "-C = %d", 13,
                "D = %s", 13,
                "-D = %s", 13,
                "E = %s", 13,
                "-E = %s", 13,
                "F = %s", 13,
                "-F = %s", 0
            
.data?
      buffer db 256 dup(?)
      bufferPlusD db 16 dup(?)
      bufferMinusD db 16 dup(?)
      bufferPlusE db 16 dup(?)
      bufferMinusE db 16 dup(?)
      bufferPlusF db 16 dup(?)
      bufferMinusF db 16 dup(?)
	  
.code
main:
    invoke FloatToStr2, doublePlusD, ADDR bufferPlusD
    invoke FloatToStr2, doubleMinusD, ADDR bufferMinusD
    invoke FloatToStr, doublePlusE, ADDR bufferPlusE
    invoke FloatToStr, doubleMinusE, ADDR bufferMinusE
    invoke FloatToStr, doublePlusF, ADDR bufferPlusF
    invoke FloatToStr, doubleMinusF, ADDR bufferMinusF       
    invoke wsprintf, ADDR buffer, ADDR format, ADDR string,
	dwordPlusA, dwordMinusA,
	dwordPlusB, dwordMinusB,
	dwordPlusC, dwordMinusC,
	ADDR bufferPlusD, ADDR bufferMinusD,
	ADDR bufferPlusE, ADDR bufferMinusE,
	ADDR bufferPlusF, ADDR bufferMinusF
    invoke MessageBox, 0, ADDR buffer, ADDR strTitle, MB_OK
    invoke ExitProcess, 0
end main
