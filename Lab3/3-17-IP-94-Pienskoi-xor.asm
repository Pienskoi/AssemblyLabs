.386
.model flat, stdcall
option casemap: none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\dialogs.inc
 
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

dlgproc proto :dword, :dword, :dword, :dword

.data
    msgBoxTitle db "Student's data", 0
    dataMessage db "Full name: Pienskoi Volodymyr Viktorovych", 13,
                   "Date of birth: 28 june 2001", 13,
                   "Gradebook number: 9422", 0
    
    invalidMessage db "Invalid password", 13,
                      "%d attempts left", 0

    password db 0C7h, 02h, 0E5h, 40h, 75h, 94h, 34h, 72h
    passwordLength equ $ - password

    key db 81h, 6Bh, 86h, 34h, 47h, 0A4h, 06h, 43h
    attempts db 3

.data?
    hInstance dd ?
    buffer db 32 dup (?)

.code
start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax

    Dialog "Enter password", \
           "Arial", 8, \
           WS_OVERLAPPED or \
           WS_SYSMENU or DS_CENTER, \
           4, \
           50, 50, 300, 80, \
           4096

    DlgStatic "Enter password:", SS_CENTER, 5, 5, 280, 18, 300
    DlgEdit ES_LEFT or WS_BORDER or WS_TABSTOP, 25, 25, 250, 12, 301
    DlgButton "OK", WS_TABSTOP, 75, 40, 50, 12, IDOK
    DlgButton "Cancel", WS_TABSTOP, 175, 40, 50, 12, IDCANCEL

    CallModalDialog hInstance, 0, dlgproc, 0

    invoke ExitProcess, eax

dlgproc proc hWin:dword, uMsg:dword, wParam:dword, lParam:dword

    local hEdit :dword
    local textLength :dword

    .if uMsg == WM_COMMAND
        .if wParam == IDOK
            invoke GetDlgItem, hWin, 301
            mov hEdit, eax
            invoke GetWindowTextLength, hEdit
            mov textLength, eax
            cmp textLength, 0
            je setfocus
            inc textLength
            invoke SendMessage, hEdit, WM_GETTEXT, textLength, addr buffer
            cmp eax, passwordLength
            jne invalid
            mov edi, 0
            compare:
                mov bh, buffer[edi]
                xor bh, key[edi]
                mov bl, password[edi]
                cmp bh, bl
                jne invalid
                inc edi
                cmp edi, passwordLength
                jl compare
            valid:
                invoke MessageBox, 0, addr dataMessage, addr msgBoxTitle, MB_OK
                invoke EndDialog, hWin, 0
            invalid:
                dec attempts
                .if attempts == 0
                    invoke EndDialog, hWin, 0
                .else 
                    invoke wsprintf, addr buffer, addr invalidMessage, attempts
                    invoke GetDlgItem, hWin, 300
                    invoke SetWindowText, eax, addr buffer
                .endif 
            setfocus:
                invoke SetFocus ,hEdit
                ret
        .elseif wParam == IDCANCEL
            invoke EndDialog, hWin, 0
        .endif
    .elseif uMsg == WM_CLOSE
        invoke EndDialog, hWin, 0
    .endif

    xor eax, eax
    ret

dlgproc endp

end start
