setText macro hWin, id, text
    push id
    push hWin
    call GetDlgItem; set eax to specified dialog item handle
    push offset text
    push eax
    call SetWindowText;; set text of dialog item
endm

encrypt macro data
    local loop;; local label

    mov edi, 0
    loop:
    mov bh, key[edi]
    xor data[edi], bh; do xor data with key and save result in data
    inc edi
    cmp edi, passwordLength
    jl loop
endm

comparePassword macro input, length
    local loop

    cmp length, passwordLength; compare lengths
    jne invalid
    mov edi, 0
    loop:
    mov bh, input[edi]
    mov bl, password[edi]
    cmp bh, bl;; compare passwords every char in loop
    jne invalid
    inc edi
    cmp edi, passwordLength
    jl loop           
endm