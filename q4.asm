.model small
.stack 100h

.data
buffer db 21        ; Byte 0: מקסימום אורך
       db ?         ; Byte 1: מספר תווים שהוזנו בפועל
       db 20 dup(?) ; המחרוזת עצמה

msg_input db 'Enter string: $'
msg_output db 13, 10, 'Reversed: $'

.code
main:
    mov ax, @data
    mov ds, ax

    ; הדפסת הודעת קלט
    mov ah, 09h
    lea dx, msg_input
    int 21h

    ; קלט מחרוזת עם INT 21h, AH=0Ah
    lea dx, buffer
    mov ah, 0Ah
    int 21h

    ; הגדרת מצביעים להתחלה ולסוף
    lea si, buffer + 2                ; SI מצביע לתחילת המחרוזת
    mov cl, [buffer + 1]              ; CL ← אורך בפועל
    xor ch, ch
    dec cl                            ; כי נספור מ־0
    lea di, buffer + 2
    add di, cx                        ; DI מצביע לסוף המחרוזת

reverse_loop:
    cmp si, di
    jge reverse_done                  ; אם נפגשו – סיום

    call swap                         ; החלפה בין התווים ב־SI ו־DI

    inc si
    dec di
    jmp reverse_loop

reverse_done:
    ; הדפסת ההודעה
    mov ah, 09h
    lea dx, msg_output
    int 21h

    ; הדפסת המחרוזת ההפוכה תו־תו
    lea si, buffer + 2
    mov cl, [buffer + 1]
    xor ch, ch

print_loop:
    mov dl, [si]
    mov ah, 02h
    int 21h
    inc si
    loop print_loop

    ; סיום
    mov ah, 4Ch
    int 21h

; ============================
; פונקציית SWAP
; מקבלת מצביעים ב־SI ו־DI
; ומבצעת החלפה של התווים ביניהם
; ============================
swap proc
    push ax
    push bx

    mov al, [si]     ; שמור את הערך של si
    mov bl, [di]     ; שמור את הערך של di
    mov [si], bl     ; כתוב את bl לתוך si
    mov [di], al     ; כתוב את al לתוך di

    pop bx
    pop ax
    ret
swap endp

end main