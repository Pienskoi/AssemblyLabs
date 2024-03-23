.model tiny
.dosseg

.data
    startMessage db "������ ��஫�:", 13, 10, '$'

    dataMessage db "���ᮭ���� ����� ��㤥��", 13, 10,
                   "���: ���᪮� �������� ����஢��", 13, 10,
                   "��� ஦�����: 28 ��� 2001", 13, 10,
                   "����� ����⭮� ������: 9422", '$'

    invalidMessage db "������ ��஫�. ���஡�� ��� ࠧ:", 13, 10, '$'

    password db "Fict2021"
    passwordLength equ $ - password

    buffer db 16
           db ?
           db 16 dup(0)

.code

.startup
    start:
        mov ax, 03h
        int 10h
        mov ah, 09h
        mov dx, offset startMessage
        int 21h

    input:
        mov ah, 0Ah
        mov dx, offset buffer
        int 21h

    compareLength:
        mov di, 1
        cmp buffer[di], passwordLength
        jne invalid

    prepareLoop:
        mov cx, passwordLength
        mov di, 0

    compareChar:
        mov bh, buffer[di + 2]
        mov bl, password[di]
        cmp bh, bl
        jne invalid
        inc di
        loop compareChar

    valid:
        mov ax, 03h
        int 10h
        mov ah, 09h
        mov dx, offset dataMessage
        int 21h

    exit: 
        mov ah, 4Ch
        int 21h

    invalid:
        mov ax, 03h
        int 10h
        mov ah, 09h
        mov dx, offset invalidMessage
        int 21h
        jmp input

end
